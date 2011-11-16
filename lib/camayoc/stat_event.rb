module Camayoc
  class StatEvent

    attr_accessor :type, :source, :stat, :value, :options

    # Constructor
    # * +type+ :: Symbol of stat type: count, timing, or generic
    # * +source+ :: Source of stat
    # * +stat+ :: Name of stat
    # * +value+ :: Value of stat
    # * +options+ :: Optionals options
    def initialize(type,source,stat,value,options={})
      self.type = type
      self.source = source
      self.stat = stat
      self.value = value
      self.options = options
    end

    def ns_stat
      "#{source}#{Camayoc::DELIMITER}#{stat}"
    end

  end
end
