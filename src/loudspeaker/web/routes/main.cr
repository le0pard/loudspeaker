module Loudspeaker
  module Web
    module Routes
      struct Main
        Log = ::Log.for(self)

        def initialize
          get "/" do
            "Hello World!"
          end

          get "/set" do |env|
            env.session.int("number", rand(100)) # set the value of "number"
            "Random number set."
          end

          get "/get" do |env|
            next("no number") unless env.session.int?("number")

            num = env.session.int("number") # get the value of "number"
            "Value of random number is #{num}."
          end
        end
      end
    end
  end
end
