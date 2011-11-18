if (begin; require 'camayoc/handlers/redis'; true; rescue LoadError; false end)
  class RedisTest < Test::Unit::TestCase
    def setup
      @redis = mock("redis")
      @handler = Camayoc::Handlers::Redis.new(:redis=>@redis)
    end

    def test_count_increments_correct_key_in_redis
      @redis.expects(:incrby).with("foo:bar:baz",500)
      @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","baz",500))
    end

    def test_timing_updates_redis_keys_with_timing_info
      seq = sequence("increments")
      @redis.expects(:set).with("foo:bar:time","timing").times(3)
      @redis.expects(:incrby).with("foo:bar:time:_count",1).times(3)
      @redis.expects(:incrby).with("foo:bar:time:_total",500).in_sequence(seq)
      @redis.expects(:incrby).with("foo:bar:time:_total",400).in_sequence(seq)
      @redis.expects(:incrby).with("foo:bar:time:_total",200).in_sequence(seq)
      @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",500))
      @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",400))
      @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",200))
    end

    def test_ignore_unknown_event_type
      @redis.expects(:set).never
      @handler.event(Camayoc::StatEvent.new(:throwaway,"foo:bar","time",500))
    end

  end
else
  puts "Warn: Skipping Redis test because redis gem is not installed"
end
