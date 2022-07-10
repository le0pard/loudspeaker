require "baked_file_system"
require "kemal"
require "mime"

module Loudspeaker
  module Web
    class FS
      extend BakedFileSystem
      {% if flag?(:release) %}
        {% if read_file? "#{__DIR__}/../../../../dist/favicon.ico" %}
          {% puts "baking ../../../../dist" %}
          bake_folder "../../../../dist"
        {% else %}
          {% puts "baking ../../../../public" %}
          bake_folder "../../../../public"
        {% end %}
      {% end %}
    end

    class StaticHandler < Kemal::Handler
      STATIC_DIRS = %w(/assets /favicon.ico /robots.txt)

      def requesting_static_file?(context)
        STATIC_DIRS.any? { |prefix| context.request.path.starts_with? prefix }
      end

      def call(context : HTTP::Server::Context)
        if requesting_static_file?(context)
          file = FS.get?(context.request.path)
          return call_next(context) if file.nil?

          slice = Bytes.new file.size
          file.read slice
          return send_file(context, slice, MIME.from_filename(file.path))
        end
        call_next context
      end
    end
  end
end
