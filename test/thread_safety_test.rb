class ThreadSafetyTest < Test::Unit::TestCase

  class SafeThing
    include Camayoc::ThreadSafety
  end

  def setup
    @thing = SafeThing.new
  end

  def test_thread_safe_turns_on_lock
    @thing.thread_safe = true
    assert_equal(Mutex,@thing.__send__(:lock).class)
  end

  def test_lock_is_placebo_by_default
    assert_equal(Camayoc::ThreadSafety::PlaceboLock,
      @thing.__send__(:lock).class)
  end

  def test_synchronize_yields_whether_safe_or_not
    yielded = false
    @thing.thread_safe = true
    @thing.synchronize { yielded = true }
    assert(yielded)
    
    yielded = false
    @thing.thread_safe = false
    @thing.synchronize {yielded = true}
    assert(yielded)
  end

end