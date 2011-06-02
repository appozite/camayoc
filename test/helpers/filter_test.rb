class FilterTest < Test::Unit::TestCase
  
  def setup
    @handler = mock("handler")
  end

  def test_constructor_block_used_as_filter
    filter = Camayoc::Handlers::Filter.new(@handler) do |type,event|
      event.stat.length > 5
    end
    @handler.expects(:count).once
    @handler.expects(:timing).once
    filter.count(Camayoc::StatEvent.new("foo:bar","short",500))
    filter.count(Camayoc::StatEvent.new("foo:bar","very_long",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","short",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","very_long",500))
  end

  def test_with_filters_on_namespaced_stat
    filter = Camayoc::Handlers::Filter.new(@handler,:with=>/a{2}/)
    @handler.expects(:count).once
    @handler.expects(:timing).once
    filter.count(Camayoc::StatEvent.new("foo:bar","aa_blah",500))
    filter.count(Camayoc::StatEvent.new("foo:bar","bb_blah",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","aa_blah",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","bb_blah",500))
  end

  def test_constructor_block_used_as_filter
    filter = Camayoc::Handlers::Filter.new(@handler,
      :if=>Proc.new{|type,event| type == :timing && event.value > 1000 })
    
    @handler.expects(:count).never
    @handler.expects(:timing).once
    filter.count(Camayoc::StatEvent.new("foo:bar","short",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","short",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","very_long",1500))
  end

  def test_constructor_block_used_as_filter
    filter = Camayoc::Handlers::Filter.new(@handler,
      :unless=>Proc.new{|type,event| type == :count })
    
    @handler.expects(:count).never
    @handler.expects(:timing).twice
    filter.count(Camayoc::StatEvent.new("foo:bar","short",500))
    filter.count(Camayoc::StatEvent.new("foo:bar","very_long",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","short",500))
    filter.timing(Camayoc::StatEvent.new("foo:bar","very_long",1500))
  end

  
end