require "totem"
require "dexter"
require "redis"

module Loudspeaker
  # config structures
  struct ConfigInfoDatabase
    include YAML::Serializable

    property path : String
  end

  struct ConfigInfoLogger
    include YAML::Serializable

    property level : String
    property format : String
  end

  struct ConfigInfoRedis
    include YAML::Serializable

    property url : String
    property pool_size : Int32
    property pool_timeout : Int32
  end

  struct ConfigInfoWeb
    include YAML::Serializable

    property enabled : Bool
    property host_binding : String
    property port : Int32
  end

  struct ConfigInfo
    include YAML::Serializable

    property secret_key_base : String

    property database : ConfigInfoDatabase
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
      # defaults
      totem.set_defaults({
        "database" => {
          "path" => "~/.loudspeaker/database.sqlite",
        },
        "logger" => {
          "level"  => "info",
          "format" => "text",
        },
        "redis" => {
          "url"          => "redis://127.0.0.1:6379/0",
          "pool_size"    => 20,
          "pool_timeout" => 5,
        },
        "web" => {
          "enabled"      => true,
          "host_binding" => "0.0.0.0",
          "port"         => 8000,
        },
      })
      # envs
      totem.automatic_env("LOUDSPEAKER")
      totem.bind_env("secret_key_base", "SECRET_KEY_BASE")
      totem.bind_env("database.path", "DATABASE_PATH")
      totem.bind_env("logger.level", "LOGGER_LEVEL")
      totem.bind_env("logger.format", "LOGGER_FORMAT")
      totem.bind_env("redis.url", "REDIS_URL")
      totem.bind_env("redis.pool_size", "REDIS_POOL_SIZE")
      totem.bind_env("redis.pool_timeout", "REDIS_POOL_TIMEOUT")
      totem.bind_env("web.enabled", "WEB_ENABLED")
      totem.bind_env("web.host_binding", "WEB_HOST_BINDING")
      totem.bind_env("web.port", "WEB_PORT")
      # autoload
      if config_file.nil?
        totem.load!
      else
        totem = Totem.from_file config_file
      end
      # config mapping
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
        pool_timeout: @config.redis.pool_timeout
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
