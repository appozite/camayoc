module Camayoc
  module Handlers

    # Write stats to a logger. Specify the method to call on the logger instance
    # with :method (usually something like :info). If not :method is specified
    # :debug will be called on the logger. You can control the format of the
    # message passed to the logger method using the :formatter Proc.
    class Logger

      attr_accessor :logger, :method, :formatter

      def initialize(logger, options={}, &block)
        self.logger = logger
        self.method = options[:method]
        if block_given?
          self.formatter = block
        else
          self.formatter = (options[:formatter] || default_formatter)
        end
      end

      def event(ev)
        msg = formatter.call(ev)
        if @method
          @logger.send(@method,msg)
        else
          @logger.debug(msg)
        end
      end

      def default_formatter
        Proc.new do |event|
          "#{event.type} #{event.ns_stat} #{event.value} #{Time.now.utc.to_i}"
        end
      end

    end
  end
end
