require "kemal"
require "kemal-session"
require "../config"
require "./handlers/*"
require "./session/*"

module Loudspeaker
  module Web
    class Server
      Log = ::Log.for(self)

      def initialize
        # Matches GET "http://host:port/"
        get "/" do
          "Hello World!"
        end

        get "/set" do |env|
          env.session.int("number", rand(100)) # set the value of "number"
          "Random number set."
        end

        get "/get" do |env|
          next("no number") unless env.session.int?("number")

          num = env.session.int("number") # get the value of "number"
          "Value of random number is #{num}."
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
        Kemal.config.host_binding = Config.config.web.host_binding
        Kemal.config.port = Config.config.web.port
        Kemal.run
      end
    end
  end
end
