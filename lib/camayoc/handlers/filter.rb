module Camayoc
  module Handlers
    class Filter

      def initialize(dest,options={},&block)
        @dest = dest
        if block_given?
          @filter = block
        elsif options[:with]
          pattern = options[:with]
          @filter = Proc.new {|type,event| event.ns_stat =~ pattern }
        elsif options[:if]
          @filter = options[:if]
        elsif options[:unless]
          proc = options[:unless]
          @filter = Proc.new do |type,event|
            !proc.call(type,event)
          end
        else
          @filter = Proc.new {|args| true }
        end
      end

      def event(ev)
        case ev.type
          when :count then count(ev)
          when :timing then timing(ev)
        end
      end

      private
        def count(event)
          if allowed?(:count,event)
            @dest.count(event)
          end
        end

        def timing(event)
          if allowed?(:timing,event)
            @dest.timing(event)
          end
        end

        def allowed?(type,event)
          @filter.call(type,event)
        end

    end
  end
end
