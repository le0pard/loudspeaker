require "kemal"

module Loudspeaker
  module Web
    class LogHandler < Kemal::BaseLogHandler
      Log = ::Log.for("web")

      def call(context : HTTP::Server::Context)
        elapsed_time = Time.measure { call_next context }
        elapsed_text = elapsed_text(elapsed_time)

        Log.dexter.debug do
          {
            status:  context.response.status_code,
            method:  context.request.method,
            path:    context.request.resource,
            time:    elapsed_text,
            message: "Response from web",
          }
        end

        context
      end

      def write(message : String)
        Log.debug { message }
      end

      private def elapsed_text(elapsed : Time::Span)
        millis = elapsed.total_milliseconds
        return "#{millis.round(2)}ms" if millis >= 1

        "#{(millis * 1000).round(2)}µs"
      end
    end
  end
end
