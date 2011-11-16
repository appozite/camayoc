module Camayoc
  module Handlers
    class Memory

      include ThreadSafety

      DEFAULT_MAX_EVENTS = 1024

      attr_reader :max_events

      def initialize(options={})
        @data = {}
        @max_events = options[:max_events].to_i rescue 0
        @max_events = DEFAULT_MAX_EVENTS if @max_events <= 0
        self.thread_safe = Camayoc.thread_safe?
      end

      def event(ev)
        case ev.type
          when :count then count(ev)
          when :timing then timing(ev)
          when :generic then generic(ev)
        end
      end

      def get(stat)
        synchronize do
          @data[stat]
        end
      end
      alias_method :[], :get

      private
        def count(ev)
          stat = ev.ns_stat
          synchronize do
            @data[stat] ||= 0
            @data[stat] += ev.value
          end
        end

        def timing(ev)
          synchronize do
            (@data[ev.ns_stat] ||= Timing.new) << ev.value
          end
        end

        def generic(ev)
          stat = ev.ns_stat
          synchronize do
            @data[stat] ||= []
            @data[stat].unshift ev.value
            if @data[stat].length > @max_events
              @data[stat] = @data[stat][0,@max_events]
            end
          end
        end

    end
  end
end
