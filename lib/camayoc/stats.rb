module Camayoc
  class Stats

    attr_accessor :name, :parent, :handlers

    def initialize(name,parent=nil)
      self.name = name
      self.parent = parent
      self.handlers = []
    end

    def [](descendant_name)
      Camayoc[Camayoc.join(name,descendant_name)]
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
      count_event(StatEvent.new(name,stat,value,options))
    end

    def timing(stat,ms,options={})
      timing_event(StatEvent.new(name,stat,ms,options))
    end
    
    protected
      def count_event(event)
        each_handler do |handler|
          handler.count(event)
        end
        if parent
          parent.count_event(event)
        end
        self
      end

      def timing_event(event)
        each_handler do |handler|
          handler.timing(event)
        end
        if parent
          parent.timing_event(event)
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