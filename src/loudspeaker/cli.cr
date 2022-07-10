require "option_parser"

module Loudspeaker
  struct CLI
    def initialize
      cli_parser = OptionParser.parse do |parser|
        parser.banner = "Welcome to Loudspeaker!"

        parser.on "-v", "--version", "Show version" do
          puts "version 1.0"
          exit
        end
        parser.on "-h", "--help", "Show help" do
          puts parser
          exit
        end
        parser.unknown_args { |args, _| puts "Remaining: #{args}" }
        parser.invalid_option do |flag|
          STDERR.puts "ERROR: #{flag} is not a valid option."
          STDERR.puts parser
          exit(1)
        end
      end

      cli_parser.parse
    end

    def run
    end
  end
end
