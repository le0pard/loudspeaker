require "./web/server"

module Loudspeaker
  module Web
    extend self

    def start
      server = Loudspeaker::Web::Server.new
      server.start
    end
  end
end
