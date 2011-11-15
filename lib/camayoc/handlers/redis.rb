require 'redis'

module Camayoc
  module Handlers

    # This class is experimental.
    class Redis

      def initialize(options={})
        @namespace = options.delete(:namespace)
        @redis = (options[:redis] || ::Redis.new(options))
      end

      def event(ev)
        case ev.type
          when :count  then count(ev)
          when :timing then timing(ev)
        end
      end

      def get(stat)
        value = @redis.get(key(stat))
        if value == "timing"
          Timing.new(
            @redis.get(key("#{stat}:_total")).to_i,
            @redis.get(key("#{stat}:_count")).to_i,
            nil,nil # Don't support min and max right now in redis
          )
        elsif value
          value.to_i
        else
          nil
        end
      end
      alias_method :[], :get

      private
        def count(event)
          @redis.incrby(key(event.ns_stat),event.value)
        end

        def timing(event)
          stat = event.ns_stat
          ms = event.value
          @redis.set(key(stat),"timing")
          @redis.incrby(key("#{stat}:_count"),1)
          @redis.incrby(key("#{stat}:_total"),ms)
        end

        def key(stat)
          @namespace ? "#{@namespace}:#{stat}" : stat
        end

    end
  end
end
