require "./loudspeaker/cli"
require "./loudspeaker/version"

module Loudspeaker
  extend self

  def main
    Loudspeaker::CLI.start(ARGV)
  end
end

Loudspeaker.main
