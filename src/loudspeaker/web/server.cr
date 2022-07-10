require "kemal"
require "kemal-session"
require "./handlers/*"

module Loudspeaker
  module Web
    class Server
      def initialize
        Kemal.config.logging = false

        # Matches GET "http://host:port/"
        get "/" do
          "Hello World!"
        end

        static_headers do |response|
          response.headers.add("Access-Control-Allow-Origin", "*")
        end

        {% if flag?(:release) %}
          # when building for relase, embed the static files in binary
          # Logger.debug "We are in release mode. Using embedded static files."
          serve_static false
          add_handler Loudspeaker::Web::StaticHandler.new
        {% else %}
          serve_static({"gzip" => true, "dir_listing" => false})
        {% end %}

        Kemal::Session.config do |config|
          config.cookie_name = "__loudspeaker_session"
          config.secret = "a_secret"
          config.timeout = 365.days
          # config.engine = Session::RedisEngine.new(host: "localhost", port: 6379, key_prefix: "session:")
          # config.timeout = Time::Span.new(1, 0, 0)
        end
      end

      def start
        # Logger.debug "Starting Kemal server"
        {% if flag?(:release) %}
          Kemal.config.env = "production"
        {% end %}
        Kemal.config.host_binding = "0.0.0.0"
        Kemal.config.port = 3000
        Kemal.run
      end
    end
  end
end
