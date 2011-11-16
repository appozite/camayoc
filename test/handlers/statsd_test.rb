class StatsdTest < Test::Unit::TestCase

  def setup
    @statsd = Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234)
  end

  def test_count_sends_correct_statsd_message
    expect_message("foo.bar.baz:500|c")
    @statsd.event(Camayoc::StatEvent.new(:count,"foo:bar","baz",500,{}))
  end

  def test_timing_sends_correct_statsd_message
    expect_message("foo.bar.time:100|ms")
    @statsd.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100,{}))
  end

  def test_generic_sends_count_statsd_message
    expect_message("foo.bar.beep:1|c")
    @statsd.event(Camayoc::StatEvent.new(:count,"foo:bar","beep",1,{}))
  end

  private
    def expect_message(message)
      @statsd.__send__(:socket).expects(:send).with(message,0,"localhost",1234)
    end

    def never_expect_message
      @statsd.__send__(:socket).expects(:send).never
    end

end
