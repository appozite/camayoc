module Camayoc
  class StatEvent

    attr_accessor :source, :stat, :value, :options

    def initialize(source,stat,value,options)
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