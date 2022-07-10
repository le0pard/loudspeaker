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

      def request_path_startswith(env, ary)
        ary.any? { |prefix| env.request.path.starts_with? prefix }
      end

      def requesting_static_file(env)
        request_path_startswith env, STATIC_DIRS
      end

      def call(env)
        if requesting_static_file(env)
          file = FS.get?(env.request.path)
          return call_next(env) if file.nil?

          slice = Bytes.new file.size
          file.read slice
          return send_file(env, slice, MIME.from_filename(file.path))
        end
        call_next env
      end
    end
  end
end
