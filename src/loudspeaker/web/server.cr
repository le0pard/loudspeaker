require "kemal"
require "kemal-session"
require "../config"
require "./handlers/*"

module Loudspeaker
  module Web
    class Server
      Log = ::Log.for(self)

      def initialize
        # Matches GET "http://host:port/"
        get "/" do
          "Hello World!"
        end

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
          config.cookie_name = "__loudspeaker_session"
          config.secret = "a_secret"
          config.timeout = 365.days
          # config.engine = Session::RedisEngine.new(host: "localhost", port: 6379, key_prefix: "session:")
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
        Kemal.config.host_binding = Config.config.web.host_binding
        Kemal.config.port = Config.config.web.port
        Kemal.run
      end
    end
  end
end
