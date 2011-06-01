module Camayoc
  module Handlers
    class IO

      include ThreadSafety

      def initialize(io=$stdout,options={})
        @io = io
        self.thread_safe = Camayoc.thread_safe?
      end

      def count(event)
        puts(:c,event.ns_stat,event.value)
      end

      def timing(event)
        puts(:t,event.ns_stat,event.value)
      end

      private
        def puts(type,stat,value)
          synchronize do
            @io.puts("#{type} #{stat} #{value} #{Time.now.utc.to_i}")
          end
        end

    end
  end
end