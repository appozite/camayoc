class LoggerTest < Test::Unit::TestCase

  def setup
    @dest_logger = mock("logger")
    @handler = Camayoc::Handlers::Logger.new(@dest_logger)
  end

  def test_count_sends_correct_log_message
    expect_message(:debug, /count foo:bar:baz 500/)
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","baz",500))
  end

  def test_timing_sends_correct_log_message
    expect_message(:debug,/timing foo:bar:time 100/)
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
  end

  def test_method_option_changes_method_called_on_logger
    @handler.method = :info
    expect_message(:info,/timing foo:bar:time 100/)
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
    expect_message(:info, /count foo:bar:baz 5000/)
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","baz",5000))
  end

  def test_formatter_changes_format_of_message
    @handler.formatter = Proc.new{|type,event| "#{type}: #{event.ns_stat}"}
    expect_message(:debug,/timing: foo:bar:time/)
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
  end

  def test_ignore_unknown_event_type
    @handler.expects(:count).never
    @handler.expects(:timing).never
    @handler.event(Camayoc::StatEvent.new(:throwaway,"foo:bar","time",500))
  end

  private
    def expect_message(method,message)
      @dest_logger.expects(method).with(regexp_matches(message))
    end

end
