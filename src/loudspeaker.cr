require "./loudspeaker/cli"
require "./loudspeaker/version"

module Loudspeaker
end

def main
  cli = Loudspeaker::CLI.new
  cli.run
end

main()
