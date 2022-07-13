require "colorize"

module Loudspeaker
  module Utils
    extend self

    def teardown
      Config.db.close
    end

    def teardown_with_error(exception : Exception, message : String)
      puts message.colorize(:red)
      puts exception.colorize(:red)
      teardown
      Process.exit 1
    end
  end
end
