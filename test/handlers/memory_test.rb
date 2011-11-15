class MemoryTest < Test::Unit::TestCase

  def setup
    @handler = Camayoc::Handlers::Memory.new
  end

  def test_count_initializes_to_0_and_increments_value
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","count",100))
    assert_equal(100,@handler["foo:bar:count"])
  end

  def test_multiple_counts_increments_value
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","count",100))
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","count",500))
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","count",400))
    assert_equal(1000,@handler["foo:bar:count"])
  end

  def test_timing_initializes_timing_object_and_adds_data
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",500))
    timing = @handler["foo:bar:time"]
    assert_not_nil(timing)
    assert_equal(1,timing.count)
  end

  def test_timing_increments_timing_object
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",600))
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",1000))
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",500))
    timing = @handler["foo:bar:time"]
    assert_equal(4,timing.count)
    assert_equal(100,timing.min)
    assert_equal(1000,timing.max)
    assert_equal(2200,timing.total)
    assert_equal(550,timing.average)
  end

  def test_ignore_unknown_event_type
    @handler.expects(:count).never
    @handler.expects(:timing).never
    @handler.event(Camayoc::StatEvent.new(:throwaway,"foo:bar","time",500))
  end
end
