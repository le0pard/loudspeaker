require "./utils"

module Loudspeaker
  module Web
    module Routes
      struct Main
        Log = ::Log.for(self)

        def initialize
          get "/" do
            layout "home"
          end

          get "/set" do |env|
            env.session.int("number", rand(100)) # set the value of "number"
            layout "home"
          end

          get "/get" do |env|
            next("no number") unless env.session.int?("number")

            env.session.int("number") # get the value of "number"
            layout "home"
          end
        end
      end
    end
  end
end
