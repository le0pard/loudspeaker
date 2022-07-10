require "./loudspeaker/cli"
require "./loudspeaker/version"

module Loudspeaker
  extend self

  def main
    cli = Loudspeaker::CLI.new
    cli.run
  end
end

Loudspeaker.main
