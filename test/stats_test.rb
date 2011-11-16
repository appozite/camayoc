class StatsTest < Test::Unit::TestCase

  include EventTestHelper

  def setup
    @stats = Camayoc::Stats.new("foo:bar")
    @handler = mock("handler1")
    @stats.add(@handler)
  end

  with_event_types("test_event_fires_to_all_handlers") do
    h2 = mock("handler2")
    @stats.add(h2)

    @handler.expects(:event).with(kind_of(Camayoc::StatEvent))
    h2.expects(:event).with(kind_of(Camayoc::StatEvent))
    @stats.send(@event_method,"beep",500)
  end

  with_event_types("test_generates_correct_stat_event") do
    @handler.expects(:event).with(
      &stat_event_match(@event_type,"foo:bar","beep",500,{:pass_through=>true}))
    @stats.send(@event_method,"beep",500,:pass_through=>true)
  end

  with_event_types("test_propagates_event_to_parent_after_firing_to_handlers") do
    @stats.parent = Camayoc::Stats.new("foo")

    seq = sequence("firing")
    evt = stat_event_match(@event_type,"foo:bar","beep",100,{:pass_through=>true})
    @handler.expects(:event).with(&evt).in_sequence(seq)
    @stats.parent.expects(:propagate_event).with(&evt).in_sequence(seq)

    @stats.send(@event_method,"beep",100,:pass_through=>true)
  end

  def test_increment_delegates_to_count
    @stats.expects(:count).with("count",1,{})
    @stats.increment("count")
  end

  def test_decrement_delegates_to_count
    @stats.expects(:count).with("count",-1,{})
    @stats.decrement("count")
  end

  def test_handler_errors_are_swallowed_and_firing_continues
    h2 = mock("handler2")
    @stats.add(h2)

    seq = sequence("firing")
    @handler.expects(:event).raises("FAIL").in_sequence(seq)
    h2.expects(:event).in_sequence(seq)

    assert_nothing_raised do
      @stats.count("baz",100)
    end
  end

end
