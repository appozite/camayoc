class StatsdTest < Test::Unit::TestCase
  
  def setup
    @statsd = Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234)
  end
  
  def test_count_sends_correct_statsd_message
    expect_message("foo.bar.baz:500|c")
    @statsd.count(Camayoc::StatEvent.new("foo:bar","baz",500,{}))
  end

  def test_timing_sends_correct_statsd_message
    expect_message("foo.bar.time:100|ms")
    @statsd.timing(Camayoc::StatEvent.new("foo:bar","time",100,{}))
  end

  private
    def expect_message(message)
      @statsd.instance_variable_get("@socket").expects(:send).with(message,0,"localhost",1234)
    end

end