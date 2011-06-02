module Camayoc
  module Handlers
    
    # Write stats to a logger. Specify the method to call on the logger instance 
    # with :method (usually something like :info). If not :method is specified 
    # :debug will be called on the logger. You can control the format of the 
    # message passed to the logger method using the :formatter Proc.
    class Logger

      attr_accessor :logger, :method, :formatter

      def initialize(logger, options={})
        self.logger = logger
        self.method = options[:method]
        self.formatter = (options[:formatter] || default_formatter)
      end

      def count(event)
        write(:count,event)
      end

      def timing(event)
        write(:timing,event)
      end

      def default_formatter
        Proc.new do |type,event|
          "#{type} #{event.ns_stat} #{event.value} #{Time.now.utc.to_i}"
        end
      end     

      protected
        def write(type,event)
          msg = formatter.call(type,event) 
          if @method
            @logger.send(@method,msg)
          else
            @logger.debug(msg)
          end
        end

    end
  end
end