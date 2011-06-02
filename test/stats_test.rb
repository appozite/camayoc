class StatsTest < Test::Unit::TestCase

  def setup
    @stats = Camayoc::Stats.new("foo:bar")
    @handler = mock("handler1")
    @stats.add(@handler)
  end

  def test_count_fires_to_all_handlers
    h2 = mock("handler2")
    @stats.add(h2)
    
    @handler.expects(:count).with(kind_of(Camayoc::StatEvent))
    h2.expects(:count).with(kind_of(Camayoc::StatEvent))
    @stats.count("count",500)
  end
  
  def test_count_generates_correct_stat_event
    @handler.expects(:count).with(
      &stat_event_match("foo:bar","count",500,{:pass_through=>true}))
    @stats.count("count",500,:pass_through=>true)
  end

  def test_count_propagates_event_to_parent_after_firing_to_handlers
    @stats.parent = Camayoc::Stats.new("foo")

    seq = sequence("firing")
    evt = stat_event_match("foo:bar","count",100,{:pass_through=>true})
    @handler.expects(:count).with(&evt).in_sequence(seq)
    @stats.parent.expects(:count_event).with(&evt).in_sequence(seq)
    
    @stats.count("count",100,:pass_through=>true)
  end

  def test_increment_delegates_to_count
    @stats.expects(:count).with("count",1,{})
    @stats.increment("count")
  end

  def test_decrement_delegates_to_count
    @stats.expects(:count).with("count",-1,{})
    @stats.decrement("count")
  end

  def test_timing_fires_to_all_handlers
    h2 = mock("handler2")
    @stats.add(h2)
    
    @handler.expects(:timing).with(kind_of(Camayoc::StatEvent))
    h2.expects(:timing).with(kind_of(Camayoc::StatEvent))
    @stats.timing("time",500)
  end

  def test_timing_generates_correct_stat_event
    @handler.expects(:timing).with(
      &stat_event_match("foo:bar","time",1,{:pass_through=>true}))
    @stats.timing("time",1,:pass_through=>true)
  end

  def test_timing_propagates_event_to_parent_after_firing_to_handlers
    @stats.parent = Camayoc::Stats.new("foo")

    seq = sequence("firing")
    evt = stat_event_match("foo:bar","time",100,{:pass_through=>true})
    @handler.expects(:timing).with(&evt).in_sequence(seq)
    @stats.parent.expects(:timing_event).with(&evt).in_sequence(seq)
    
    @stats.timing("time",100,:pass_through=>true)
  end

  def test_handler_errors_are_swallowed_and_firing_continues
    h2 = mock("handler2")
    @stats.add(h2)

    seq = sequence("firing")
    @handler.expects(:count).raises("FAIL").in_sequence(seq)
    h2.expects(:count).in_sequence(seq)

    assert_nothing_raised do
      @stats.count("baz",100)
    end
  end

  private
    def stat_event_match(*args)
      template = Camayoc::StatEvent.new(*args)
      Proc.new do |event|
        event.source == template.source &&
          event.stat == template.stat &&
          event.value == template.value &&
          event.options == template.options
      end
    end
end