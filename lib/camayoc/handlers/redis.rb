require 'redis'

module Camayoc
  module Handlers
    class Redis
      
      def initialize(options={})
        @namespace = options.delete(:namespace)
        @redis = (options[:redis] || ::Redis.new(options))
      end

      def count(event)
        @redis.incrby(key(event.ns_stat),event.value)
      end

      def timing(event)
        stat = event.ns_stat
        ms = event.value
        @redis.set(key(stat),"timing")
        @redis.incrby(key("t:count:#{stat}"),1)
        @redis.incrby(key("t:total:#{stat}"),ms)
        zkey = key("t:range:#{stat}")
        @redis.zadd(zkey,ms,ms)
        @redis.zremrangebyrank(zkey,1,-2)
      end

      def get(stat)
        value = @redis.get(key(stat))
        if value == "timing"
          range = @redis.zrange(key("t:range:#{stat}"),0,-1)
          Timing.new(
            @redis.get(key("t:total:#{stat}")).to_i, 
            @redis.get(key("t:count:#{stat}")).to_i,
            range.first.to_i, 
            range.last.to_i
          )
        else
          value.to_i
        end
      end
      alias_method :[], :get

      private
        def key(stat)
          @namespace ? "#{@namespace}:#{stat}" : stat
        end

    end
  end
end