require "http/server"

module WebAdmin
  class Base
    def initialize
      # allow @routes to save Proc as its value
      @routes = {} of String => (-> String)
    end

    def run
      server = HTTP::Server.new([
        HTTP::ErrorHandler.new,
        HTTP::LogHandler.new,
        HTTP::CompressHandler.new,
      ]) do |context|
        if @routes.has_key?(context.request.path.to_s)
          # add call method to proc when returned
          context.response.content_type = "text/plain"
          context.response.print(@routes[context.request.path.to_s].call)
        else
          context.response.status = HTTP::Status::NOT_FOUND
          context.response.print("Not found")
        end
      end
      address = server.bind_tcp "0.0.0.0", 8080
      puts "Listening on http://#{address}"
      server.listen
    end

    # add method to dynamically add routes
    def get(route, &block : (-> String))
      @routes[route.to_s] = block
    end
  end
end

app = WebAdmin::Base.new

# the app will respond with the returned string
app.get "/" do
  "hello world"
end

# you can also exec code in block and return a string value
app.get "/app" do
  a = "hello 1111"
  b = "world 1111"
  "#{a} #{b}"
end

app.run
