module Camayoc
  module Handlers
    class Filter

      # Constructor - by default, returns true
      # * +dest+ :: Handler
      # * +options[]+
      # * +  :with+ :: Regexp matching against event namespace
      # * +  :if+ :: Proc taking type and event returning true
      # * +  :unless+ :: Converse of +if+
      def initialize(dest,options={},&block)
        @dest = dest
        if block_given?
          @filter = block
        elsif options[:with]
          pattern = options[:with]
          @filter = Proc.new {|event| event.ns_stat =~ pattern }
        elsif options[:if]
          @filter = options[:if]
        elsif options[:unless]
          proc = options[:unless]
          @filter = Proc.new do |event|
            !proc.call(event)
          end
        else
          @filter = Proc.new { true }
        end
      end

      def event(ev)
        if @filter.call(ev)
          @dest.event(ev)
        end
      end

    end
  end
end
