require "json"
require "redis"
require "kemal-session"

module Loudspeaker
  module Web
    class Session
      class RedisEngine < Kemal::Session::Engine
        class StorageInstance
          macro define_storage(vars)
            include JSON::Serializable

            {% for name, type in vars %}
              property {{name.id}}s : Hash(String, {{type}})
            {% end %}

            {% for name, type in vars %}
              def {{name.id}}(k : String) : {{type}}
                return @{{name.id}}s[k]
              end

              def {{name.id}}?(k : String) : {{type}}?
                return @{{name.id}}s[k]?
              end

              def {{name.id}}(k : String, v : {{type}})
                @{{name.id}}s[k] = v
              end
            {% end %}

            def initialize
              {% for name, type in vars %}
                @{{name.id}}s = Hash(String, {{type}}).new
              {% end %}
            end
          end

          define_storage({
            int:    Int32,
            bigint: Int64,
            string: String,
            float:  Float64,
            bool:   Bool,
            object: Kemal::Session::StorableObject::StorableObjectContainer,
          })
        end

        @redis : Redis::PooledClient
        @cache : StorageInstance
        @cached_session_id : String

        def initialize(client : Redis::PooledClient, key_prefix = "session:")
          @redis = client

          @cache = StorageInstance.new
          @key_prefix = key_prefix
          @cached_session_id = ""
        end

        def run_gc
          # Do Nothing. All the sessions should be set with the
          # expiration option on the keys. So long as the redis instance
          # hasn't been set up with maxmemory policy of noeviction
          # then this should be fine. `noeviction` will cause the redis
          # instance to fill up and keys will not expire from the instance
        end

        def prefix_session(session_id : String)
          "#{@key_prefix}#{session_id}"
        end

        def parse_session_id(key : String)
          key.sub(@key_prefix, "")
        end

        def load_into_cache(session_id)
          @cached_session_id = session_id
          value = @redis.get(prefix_session(session_id))
          if !value.nil?
            @cache = StorageInstance.from_json(value)
          else
            @cache = StorageInstance.new
            @redis.set(
              prefix_session(session_id),
              @cache.to_json,
              ex: Kemal::Session.config.timeout.total_seconds.to_i
            )
          end
          @cache
        end

        def save_cache
          @redis.set(
            prefix_session(@cached_session_id),
            @cache.to_json,
            ex: Kemal::Session.config.timeout.total_seconds.to_i
          )
        end

        def is_in_cache?(session_id)
          session_id == @cached_session_id
        end

        def create_session(session_id : String)
          load_into_cache(session_id)
        end

        def get_session(session_id : String) : Kemal::Session?
          value = @redis.get(prefix_session(session_id))

          return Kemal::Session.new(session_id) if value
          nil
        end

        def destroy_session(session_id : String)
          @redis.del(prefix_session(session_id))
        end

        def destroy_all_sessions
          cursor = 0
          loop do
            cursor, keys = @redis.scan(cursor, "#{@key_prefix}*")
            keys = keys.as(Array(Redis::RedisValue)).map(&.to_s)
            keys.each do |key|
              @redis.del(key)
            end
            break if cursor == "0"
          end
        end

        def all_sessions : Array(Kemal::Session)
          arr = [] of Kemal::Session

          each_session do |session|
            arr << session
          end

          arr
        end

        def each_session
          cursor = 0
          loop do
            cursor, keys = @redis.scan(cursor, "#{@key_prefix}*")
            keys = keys.as(Array(Redis::RedisValue)).map(&.to_s)
            keys.each do |key|
              yield Kemal::Session.new(parse_session_id(key.as(String)))
            end
            break if cursor == "0"
          end
        end

        macro define_delegators(vars)
          {% for name, type in vars %}
            def {{name.id}}(session_id : String, k : String) : {{type}}
              load_into_cache(session_id) unless is_in_cache?(session_id)
              return @cache.{{name.id}}(k)
            end

            def {{name.id}}?(session_id : String, k : String) : {{type}}?
              load_into_cache(session_id) unless is_in_cache?(session_id)
              return @cache.{{name.id}}?(k)
            end

            def {{name.id}}(session_id : String, k : String, v : {{type}})
              load_into_cache(session_id) unless is_in_cache?(session_id)
              @cache.{{name.id}}(k, v)
              save_cache
            end

            def {{name.id}}s(session_id : String) : Hash(String, {{type}})
              load_into_cache(session_id) unless is_in_cache?(session_id)
              return @cache.{{name.id}}s
            end
          {% end %}
        end

        define_delegators({
          int:    Int32,
          bigint: Int64,
          string: String,
          float:  Float64,
          bool:   Bool,
          object: Kemal::Session::StorableObject::StorableObjectContainer,
        })
      end
    end
  end
end
