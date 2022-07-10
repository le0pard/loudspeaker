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

serve_static({"gzip" => true, "dir_listing" => false})

static_headers do |response|
  response.headers.add("Access-Control-Allow-Origin", "*")
end

Kemal::Session.config do |config|
  config.cookie_name = "__loudspeaker_session"
  config.secret = "a_secret"
  config.timeout = 365.days
  # config.engine = Session::RedisEngine.new(host: "localhost", port: 6379, key_prefix: "session:")
  # config.timeout = Time::Span.new(1, 0, 0)
end

Kemal.config.logging = false
Kemal.config.host_binding = "0.0.0.0"
Kemal.config.port = 3000
Kemal.run
