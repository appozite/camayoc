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

  def test_any_other_event_type_is_treated_as_a_count_with_value_if_value_is_integer
    expect_message("foo.bar.beep:25|c")
    @statsd.event(Camayoc::StatEvent.new(:foo,"foo:bar","beep",25,{}))
  end

  def test_any_other_event_type_is_treated_as_a_count_with_value_if_value_is_string_integer_representation
    expect_message("foo.bar.beep:31|c")
    @statsd.event(Camayoc::StatEvent.new(:foo,"foo:bar","beep","31",{}))
  end

  def test_any_other_event_type_is_treated_as_a_count_of_1_if_value_is_not_convertable_to_integer
    expect_message("foo.bar.beep:1|c")
    @statsd.event(Camayoc::StatEvent.new(:foo,"foo:bar","beep",{:a=>50},{}))
  end

  private
    def expect_message(message)
      @statsd.instance_variable_get("@socket").expects(:send).with(message,0,"localhost",1234)
    end

    def never_expect_message
      @statsd.__send__(:socket).expects(:send).never
    end

end
