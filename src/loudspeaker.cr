require "./loudspeaker/version"

require "option_parser"

OptionParser.parse do |parser|
  parser.banner = "Welcome to Loudspeaker!"

  parser.on "-v", "--version", "Show version" do
    puts "version 1.0"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

module Loudspeaker
  # include Loudspeaker::Handlers
  # include Loudspeaker::Annotations
end