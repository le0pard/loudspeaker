require "kemal"
require "kemal-session"
require "../config"
require "./handlers/*"
require "./routes/*"
require "./session/*"

module Loudspeaker
  module Web
    class Server
      Log = ::Log.for(self)

      def initialize
        # routes
        Loudspeaker::Web::Routes::Main.new

        static_headers do |response|
          response.headers.add("Access-Control-Allow-Origin", "*")
        end

        {% if flag?(:release) %}
          # when building for relase, embed the static files in binary
          Log.debug { "We are in release mode. Using embedded static files." }
          serve_static false
          add_handler Loudspeaker::Web::StaticHandler.new
        {% else %}
          serve_static({"gzip" => true, "dir_listing" => false})
        {% end %}

        Kemal.config.logging = false
        add_handler Loudspeaker::Web::LogHandler.new

        Kemal::Session.config do |config|
          config.cookie_name = "_loudspeaker_session"
          config.secret = Config.config.secret_key_base
          config.samesite = HTTP::Cookie::SameSite::Strict
          config.timeout = 365.days
          config.engine = Loudspeaker::Web::Session::RedisEngine.new(
            client: Config.redis
          )
        end
      end

      def start
        if !Config.config.web.enabled
          Log.debug { "Web server disabled" }
          return
        end

        Log.debug { "Starting web server" }
        {% if flag?(:release) %}
          Kemal.config.env = "production"
        {% end %}
        Kemal.config.disable_trap_signal = true
        Kemal.config.host_binding = Config.config.web.host_binding
        Kemal.config.port = Config.config.web.port
        Kemal.run
      end

      def stop
        Kemal.stop
      end
    end
  end
end
