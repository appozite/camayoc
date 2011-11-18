module Camayoc
  class Stats

    attr_accessor :name, :parent, :handlers

    # Constructor
    # * +name+ :: Name of stat
    # * +parent+ :: Optional parent stat (default: nil)
    def initialize(name,parent=nil)
      self.name = name
      self.parent = parent
      self.handlers = []
    end

    # Add handler with filter options
    # * +handler+ :: Handler instance
    # * +filter_opts+ :: Options for a new Handlers::Filter
    #                    instance (optional)
    def add(handler,filter_opts={})
      if !filter_opts.empty?
        handler = Handlers::Filter.new(handler,filter_opts)
      end
      self.handlers << handler
      self
    end

    # Quick alias for adding a handler
    def <<(handler)
      self.add(handler)
    end

    # Timing stat
    def timing(stat,value,options={})
      propagate(:timing,stat,value,options)
    end

    # Generic event
    def event(stat,value,options={})
      propagate(:generic,stat,value,options)
    end

    # Count and incr/decr convenience methods
    def count(stat,value,options={})
      propagate(:count,stat,value,options)
    end

    def increment(stat,options={})
      count(stat,1,options)
    end

    def decrement(stat,options={})
      count(stat,-1,options)
    end

    # Executes a block, stores the timing information in the specified stat
    # and returns the value of the block. Use this to wrap existing code with 
    # timing information without worrying about return values.
    def benchmark(stat,options={})
      result = nil
      realtime(stat,options) do
        result = yield
      end
      result
    end

    # Executes a block, stores the timing information in the specified stat
    # and returns the time **in seconds** that the execution took. This is 
    # basically a drop-in replacement for calls to Benchmark.realtime
    def realtime(stat,options={})
      start_time = Time.now
      yield
      duration = (Time.now.to_f - start_time.to_f)
      # Convert to ms for timing call
      timing(stat,(duration*1000).round,options)
      duration
    end

    protected
      # Creates new StatEvent and passes to +#propagate_event+
      def propagate(type,stat,value,options)
        propagate_event(StatEvent.new(type,name,stat,value,options))
      end

      # Propagates event to all handlers and parent Stat
      def propagate_event(ev)
        each_handler do |handler|
          handler.event(ev)
        end
        if parent
          parent.propagate_event(ev)
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
