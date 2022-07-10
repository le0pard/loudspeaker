require "totem"
require "dexter"

module Loudspeaker
  # config structures
  struct ConfigInfoLogger
    include JSON::Serializable

    property level : String
    property format : String
  end

  struct ConfigInfoWeb
    include JSON::Serializable

    property enabled : Bool
    property host_binding : String
    property port : Int32
  end

  struct ConfigInfo
    include JSON::Serializable

    property logger : ConfigInfoLogger
    property web : ConfigInfoWeb
  end

  # config instance
  class Config
    getter config : ConfigInfo

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
    end

    private def init_logger
      log_level = LOGGER_SEVERITY_MAP.fetch(@config.logger.level) { Log::Severity::Info }

      backend = Log::IOBackend.new
      if @config.logger.format.downcase == "json"
        backend.formatter = Dexter::JSONLogFormatter.proc
      end

      Log.dexter.configure(log_level, backend)
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
  end
end
