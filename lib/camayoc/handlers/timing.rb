module Camayoc
  module Handlers
    class Timing
      attr_accessor :total, :count, :min, :max
      
      def initialize(total=0,count=0,min=0,max=0)
        self.total = total
        self.count = count
        self.max = max
        self.min = min
      end

      def <<(ms)
        @total += ms
        @count += 1
        @max = ms if ms > @max
        @min = ms if ms < @min
      end
      
      def average
        return nil if @count == 0
        @total/@count
      end
    end
  end
end