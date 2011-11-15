module Camayoc
  class Stats

    attr_accessor :name, :parent, :handlers

    def initialize(name,parent=nil)
      self.name = name
      self.parent = parent
      self.handlers = []
    end

    def add(handler,filter_opts={})
      if !filter_opts.empty?
        handler = Handlers::Filter.new(handler,filter_opts)
      end
      self.handlers << handler
      self
    end

    def <<(handler)
      self.add(handler)
    end

    def increment(stat,options={})
      count(stat,1,options)
    end

    def decrement(stat,options={})
      count(stat,-1,options)
    end

    def count(stat,value,options={})
      event(:count,stat,value,options)
    end

    def timing(stat,value,options={})
      event(:timing,stat,value,options)
    end

    def event(type,stat,value,options={})
      propagate_event(StatEvent.new(type,name,stat,value,options))
    end

    protected
      def propagate_event(ev)
        each_handler do |handler|
          handler.event(ev)
        end
        if parent
          parent.event(ev)
        end
        self
      end

    private
      def each_handler
        handlers.each do |handler|
          begin
            yield(handler)
          rescue
            # Swallow up errors
          end
        end
      end

      def ns_stat(stat,ns=nil)
        "#{ns || name}#{Camayoc::NAME_DELIMITER}#{stat}"
      end

  end
end
