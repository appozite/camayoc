class IOTest < Test::Unit::TestCase

  def setup
    # Hack to get around weird Mocha issue with expecting :puts
    @io = []
    def @io.puts(msg)
      self << msg
    end
    @handler = Camayoc::Handlers::IO.new(@io)
  end

  def test_count_sends_correct_log_message
    expect_message(/count foo:bar:baz 500/)
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","baz",500))
  end

  def test_timing_sends_correct_log_message
    expect_message(/timing foo:bar:time 100/)
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
  end

  def test_formatter_changes_format_of_message
    @handler.formatter = Proc.new{|type,event| "#{type}: #{event.ns_stat}"}
    expect_message(/timing: foo:bar:time/)
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
  end

  def test_ignore_unknown_event_type
    @handler.expects(:count).never
    @handler.expects(:timing).never
    @handler.event(Camayoc::StatEvent.new(:throwaway,"foo:bar","time",500))
  end

  private
    def expect_message(*messages)
      assert(@io.zip(messages).all?{ |actual,patt| actual =~ patt })
    end

end
