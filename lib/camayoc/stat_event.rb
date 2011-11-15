module Camayoc
  class StatEvent

    attr_accessor :type, :source, :stat, :value, :options

    def initialize(type,source,stat,value,options={})
      self.source = source
      self.type = type
      self.stat = stat
      self.value = value
      self.options = options
    end

    def ns_stat
      "#{source}#{Camayoc::DELIMITER}#{stat}"
    end

  end
end
