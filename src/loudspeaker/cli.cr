require "clim"
require "./web"

macro common_option
  option "-c PATH", "--config=PATH", type: String,
    desc: "Path to the config file"
end

module Loudspeaker
  class CLI < Clim
    main do
      desc "Welcome to Loudspeaker!"
      usage "loudspeaker [sub_command] [options]"
      help short: "-h"
      version "Version #{Loudspeaker::VERSION}", short: "-v"
      common_option
      run do |opts|
        puts "Loudspeaker!"
        puts

        # empty ARGV so it won't be passed to Kemal
        ARGV.clear

        Loudspeaker::Web.start
      end
    end
  end
end
