class FilterTest < Test::Unit::TestCase

  include EventTestHelper

  def setup
    @handler = mock("handler")
  end

  with_event_types("test_constructor_block_used_as_filter") do
    filter = Camayoc::Handlers::Filter.new(@handler) do |event|
      event.stat.length > 5
    end

    @handler.expects(:event).once
    filter.event(Camayoc::StatEvent.new(@event_type,"foo:bar","short",500))
    filter.event(Camayoc::StatEvent.new(@event_type,"foo:bar","very_long",500))
  end

  with_event_types("test_with_filters_on_namespaced_stat") do
    filter = Camayoc::Handlers::Filter.new(@handler,:with=>/a{2}/)

    evt = stat_event_match(@event_type,"foo:bar","aa_blah",500)
    @handler.expects(:event).with(&evt).once
    filter.event(Camayoc::StatEvent.new(@event_type,"foo:bar","aa_blah",500))
    filter.event(Camayoc::StatEvent.new(@event_type,"foo:bar","bb_blah",500))
  end

  def test_constructor_block_used_as_filter_with_if_condition
    filter = Camayoc::Handlers::Filter.new(@handler,
      :if=>Proc.new{|event| event.type == :timing && event.value > 1000 })

    evt = stat_event_match(:timing,"foo:bar","very_long",1500)
    @handler.expects(:event).with(&evt).once
    filter.event(Camayoc::StatEvent.new(:count,"foo:bar","short",500))
    filter.event(Camayoc::StatEvent.new(:timing,"foo:bar","short",500))
    filter.event(Camayoc::StatEvent.new(:timing,"foo:bar","very_long",1500))
  end

  def test_constructor_block_used_as_filter_with_unless_condition
    filter = Camayoc::Handlers::Filter.new(@handler,
      :unless=>Proc.new{|event| event.type == :count })

    evt = stat_event_match(:timing,"foo:bar","short",500)
    @handler.expects(:event).with(&evt).once
    filter.event(Camayoc::StatEvent.new(:timing,"foo:bar","short",500))
    filter.event(Camayoc::StatEvent.new(:count,"foo:bar","short",500))
    filter.event(Camayoc::StatEvent.new(:count,"foo:bar","very_long",500))
  end

  def test_default_filter_is_always_true
    filter = Camayoc::Handlers::Filter.new(@handler)

    @handler.expects(:event).once
    filter.event(Camayoc::StatEvent.new(:counting,"foo:bar","short",500))
  end

end
