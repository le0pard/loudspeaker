require "kemal"
require "kemal-session"

# Matches GET "http://host:port/"
get "/" do
  "Hello World!"
end

# Creates a WebSocket handler.
# Matches "ws://host:port/socket"
ws "/socket" do |socket|
  socket.send "Hello from Kemal!"
end

Kemal.config do |config|
  config.serve_static = false
end
Kemal::Session.config do |config|
  config.cookie_name = "__loudspeaker_session"
  config.secret = "a_secret"
  # config.engine = Session::RedisEngine.new(host: "localhost", port: 6379, key_prefix: "session:")
  # config.timeout = Time::Span.new(1, 0, 0)
end
Kemal.run(3000)
