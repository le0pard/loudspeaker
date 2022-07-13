require "clim"
require "./config"
require "./utils"
require "./web"

macro common_option
  option "-c PATH", "--config=PATH", type: String,
    desc: "Path to the config file"
end

module Loudspeaker
  class CLI < Clim
    Log = ::Log.for(self)

    main do
      desc "Welcome to Loudspeaker!"
      usage "loudspeaker [sub_command] [options]"
      help short: "-h"
      version "Version #{Loudspeaker::VERSION}", short: "-v"
      common_option
      run do |opts|
        Log.info { "Starting Loudspeaker" }

        # empty ARGV so it won't be passed to Kemal
        ARGV.clear

        quit_signal = Channel(Nil).new

        begin
          Config.load(opts.config)
        rescue e
          Utils.teardown_with_error(e, "Error to setup configuration")
        end

        web_server = Loudspeaker::Web::Server.new

        spawn do
          begin
            web_server.start
          rescue e
            Utils.teardown_with_error(e, "Error to start web server")
          end
        end

        terminate = Proc(Signal, Nil).new do |signal|
          Log.info { "[SIG#{signal}] received graceful stop" }
          web_server.stop
          Utils.teardown
          quit_signal.send(nil)
        end

        {% for signal in %w[HUP TERM INT QUIT] %}
          Signal::{{signal.id}}.trap &terminate
        {% end %}

        quit_signal.receive

        Log.info { "Stopped Loudspeaker" }
      end
    end
  end
end
