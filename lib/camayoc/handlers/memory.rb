module Camayoc
  module Handlers
    class Memory

      include ThreadSafety

      def initialize(options={})
        @data = {}
        self.thread_safe = Camayoc.thread_safe?
      end

      def event(ev)
        case ev.type
          when :count then count(ev)
          when :timing then timing(ev)
        end
      end

      def get(stat)
        synchronize do
          @data[stat]
        end
      end
      alias_method :[], :get

      private
        def count(event)
          stat = event.ns_stat
          synchronize do
            @data[stat] ||= 0
            @data[stat] += event.value
          end
        end

        def timing(event)
          synchronize do
            (@data[event.ns_stat] ||= Timing.new) << event.value
          end
        end

    end
  end
end
