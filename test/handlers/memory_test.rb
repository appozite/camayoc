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

  def test_add_generic_event
    @handler.expects(:generic).once
    @handler.event(Camayoc::StatEvent.new(:generic,"foo:bar","time",50))
  end

  def test_safe_defaults_for_max_events_falls_back
    @handler = Camayoc::Handlers::Memory.new
    assert_equal(Camayoc::Handlers::Memory::DEFAULT_MAX_EVENTS,
      @handler.max_events)

    @handler = Camayoc::Handlers::Memory.new(:max_events=>"apple pie")
    assert_equal(Camayoc::Handlers::Memory::DEFAULT_MAX_EVENTS,
      @handler.max_events)

    @handler = Camayoc::Handlers::Memory.new(:max_events=>"0")
    assert_equal(Camayoc::Handlers::Memory::DEFAULT_MAX_EVENTS,
      @handler.max_events)

    @handler = Camayoc::Handlers::Memory.new(:max_events=>"-1")
    assert_equal(Camayoc::Handlers::Memory::DEFAULT_MAX_EVENTS,
      @handler.max_events)

    # valid value for good measure
    @handler = Camayoc::Handlers::Memory.new(:max_events=>"1")
    assert_equal(1,@handler.max_events)
  end

  def test_capped_fifo_generic_events
    max_events = 10
    @handler = Camayoc::Handlers::Memory.new(:max_events=>max_events)

    overflow = 3
    num_events = max_events + overflow

    num_events.times do |idx|
      @handler.event(Camayoc::StatEvent.new(:generic,
        "foo:bar","beep",{:idx=>idx}))
    end
    beeps = @handler['foo:bar:beep']
    assert_equal(max_events,beeps.size)
    assert_equal({:idx=>overflow+max_events-1},beeps[0])
    assert_equal({:idx=>overflow},beeps[-1])
  end

end
