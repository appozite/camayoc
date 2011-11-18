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
    @handler.event(Camayoc::StatEvent.new(:count,"foo:bar","baz",500))
    assert_message(/count foo:bar:baz 500/)
  end

  def test_timing_sends_correct_log_message
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
    assert_message(/timing foo:bar:time 100/)
  end

  def test_formatter_changes_format_of_message
    @handler.formatter = Proc.new{|event| "#{event.type}: #{event.ns_stat}"}
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
    assert_message(/timing: foo:bar:time/)
  end

  def test_formatter_can_be_set_with_constructor_block
    @handler = Camayoc::Handlers::IO.new(@io) do |event|
      "#{event.type}: #{event.ns_stat} #{event.value}"
    end
    @handler.event(Camayoc::StatEvent.new(:timing,"foo:bar","time",100))
    assert_message(/timing: foo:bar:time 100/)
  end

  def test_logs_any_event_type
    @handler.event(Camayoc::StatEvent.new(:baz,"foo:bar","time",500))
    assert_message(/baz foo:bar:time 500/)
  end

  private
    def assert_message(*messages)
      pairs = messages.zip(@io)
      assert(pairs.all?{ |actual,patt| actual =~ patt },pairs.join("\n"))
    end

end
