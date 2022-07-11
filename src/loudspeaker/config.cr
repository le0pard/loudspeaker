require "totem"
require "dexter"
require "redis"

module Loudspeaker
  # config structures
  struct ConfigInfoLogger
    include JSON::Serializable

    property level : String
    property format : String
  end

  struct ConfigInfoRedis
    include JSON::Serializable

    property url : String
    property pool_size : Int32
    property pool_timeout : Int32
  end

  struct ConfigInfoWeb
    include JSON::Serializable

    property enabled : Bool
    property host_binding : String
    property port : Int32
  end

  struct ConfigInfo
    include JSON::Serializable

    property secret_key_base : String

    property logger : ConfigInfoLogger
    property redis : ConfigInfoRedis
    property web : ConfigInfoWeb
  end

  # config instance
  class Config
    getter config : ConfigInfo
    getter redis_pool : Redis::PooledClient

    @@instance : Config?

    LOGGER_SEVERITY_MAP = {
      "debug":  Log::Severity::Debug,
      "info":   Log::Severity::Info,
      "notice": Log::Severity::Notice,
      "warn":   Log::Severity::Warn,
      "error":  Log::Severity::Error,
      "fatal":  Log::Severity::Fatal,
    }

    private def initialize(config_file : String?)
      totem = Totem.new("config", nil, [".", "~/.loudspeaker"])
      totem.automatic_env("LOUDSPEAKER")
      # defaults
      totem.set_default("logger.level", "info")
      totem.set_default("logger.format", "text")
      totem.set_default("redis.url", "redis://127.0.0.1:6379/0")
      totem.set_default("redis.pool_size", 20)
      totem.set_default("redis.pool_timeout", 5)
      totem.set_default("web.enabled", true)
      totem.set_default("web.host_binding", "0.0.0.0")
      totem.set_default("web.port", 8000)
      # autoload
      if config_file.nil?
        totem.load!
      else
        totem = Totem.from_file config_file
      end

      @config = totem.mapping(ConfigInfo)
      # prepare stuff
      init_logger
      @redis_pool = init_redis_pool
    end

    private def init_logger
      log_level = LOGGER_SEVERITY_MAP.fetch(@config.logger.level) { Log::Severity::Info }

      backend = Log::IOBackend.new
      if @config.logger.format.downcase == "json"
        backend.formatter = Dexter::JSONLogFormatter.proc
      end

      Log.dexter.configure(log_level, backend)
    end

    private def init_redis_pool
      Redis::PooledClient.new(
        url: @config.redis.url,
        pool_size: @config.redis.pool_size,
        pool_timeout: @config.redis.pool_size
      )
    end

    private def self.instance
      @@instance.not_nil!
    end

    def self.load(config_file : String?)
      @@instance = new(config_file)
    end

    def self.config
      instance.config
    end

    def self.redis
      instance.redis_pool
    end
  end
end
