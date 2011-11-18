require 'rubygems'
require 'camayoc/version'
require 'camayoc/thread_safety'
require 'camayoc/stat_event'
require 'camayoc/handlers/timing'
require 'camayoc/handlers/filter'
require 'camayoc/handlers/logger'
require 'camayoc/handlers/io'
require 'camayoc/handlers/memory'
require 'camayoc/handlers/statsd'
require 'camayoc/stats'

module Camayoc

  DELIMITER = ":"

  @registry = {}
  @lock = Mutex.new

  class << self
    def [](name)
      @lock.synchronize { @registry[name] ||= _new(name) }
    end

    def new(name)
      @lock.synchronize { _new(name) }
    end

    def all
      @lock.synchronize { @registry.values.dup }
    end

    def thread_safe=(value)
      @thread_safe = value
    end

    def thread_safe?
      @thread_safe == true
    end

    def join(*names)
      names.flatten.join(DELIMITER)
    end

    private
      def _new(name)
        stats = Stats.new(name,ancestor(name))
        @registry[name] = stats
        reassign_children(stats)
        stats
      end

      def reassign_children(node)
        @registry.values.each do |other_node|
          if other_node != node && other_node.name.index(node.name) == 0
            other_node.parent = node
          end
        end
      end

      def ancestor(name)
        ancestor = nil
        path = name.split(DELIMITER)
        while path.pop && !ancestor
          ancestor = @registry[join(path)]
        end
        ancestor
      end
  end

end
