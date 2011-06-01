require 'socket'

module Camayoc
  module Handlers
    class Statsd

      include ThreadSafety

      attr_accessor :namespace
      
      # @param [String] host your statsd host
      # @param [Integer] port your statsd port
      def initialize(options={})
        self.namespace = options[:namespace]
        @host = options[:host]
        @port = options[:port]
        self.thread_safe = Camayoc.thread_safe?
      end

      def count(event)
        send(event.ns_stat,event.value,'c',event.options[:sample_rate]||1) 
      end

      def timing(event)
        send(event.ns_stat, event.value, 'ms', event.options[:sample_rate]||1) 
      end

      private
        def sampled(sample_rate)
          yield unless sample_rate < 1 and rand > sample_rate
        end

        def send(stat, delta, type, sample_rate)
          prefix = "#{@namespace}." unless @namespace.nil?
          sampled(sample_rate) do
            stat = stat.gsub(Camayoc::DELIMITER,'.')
            msg = "#{prefix}#{stat}:#{delta}|#{type}#{'|@' << sample_rate.to_s if sample_rate < 1}"
            synchronize do
              socket.send(msg, 0, @host, @port)
            end
          end
        end

        def socket
          @socket ||= UDPSocket.new 
        end

    end
  end
end