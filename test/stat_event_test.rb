class StatsTest < Test::Unit::TestCase
 
  def test_ns_stat_uses_source_for_namespace
    event = Camayoc::StatEvent.new(:ignored,"foo:bar:baz","stat",10000,{})
    assert_equal("foo:bar:baz:stat",event.ns_stat)
  end

end
