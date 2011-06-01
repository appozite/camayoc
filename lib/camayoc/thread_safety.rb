module Camayoc
  module ThreadSafety

    class PlaceboLock
      def synchronize
        yield
      end
    end

    # Ideally this should be called from your constructor
    def thread_safe=(value)
      @lock = value ? Mutex.new : PlaceboLock.new
    end

    def thread_safe?
      lock.is_a?(Mutex)
    end

    def synchronize
      lock.synchronize { yield }
    end

    private
      def lock
        # If we get here and have to init the lock because it's nil, obviously 
        # it's not thread safe
        @lock ||= PlaceboLock.new
      end

  end
end