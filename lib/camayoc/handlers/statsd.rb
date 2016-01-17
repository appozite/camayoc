require 'socket'

# This class is a port of the code in https://github.com/reinh/statsd to fit
# with the Camayoc handler interface.
module Camayoc
  module Handlers
    class Statsd

      include ThreadSafety

      attr_accessor :namespace

      def initialize(options={})
        self.namespace = options[:namespace]
        @host = options[:host]
        @port = options[:port]
        @socket = UDPSocket.new
        @socket.connect(@host, @port)
        self.thread_safe = Camayoc.thread_safe?
      end

      def event(ev)
        case ev.type
          when :timing then timing(ev)
          when :count  then count(ev)
          else other(ev)
        end
      end

      private
        def other(ev)
          value = Integer(ev.value) rescue 1
          send(ev.ns_stat,value,'c',ev.options[:sample_rate]||1)
        end

        def count(ev)
          send(ev.ns_stat,ev.value,'c',ev.options[:sample_rate]||1)
        end

        def timing(ev)
          send(ev.ns_stat,ev.value,'ms',ev.options[:sample_rate]||1)
        end

        def sampled(sample_rate)
          yield unless sample_rate < 1 and rand > sample_rate
        end

        def send(stat, delta, type, sample_rate)
          prefix = "#{@namespace}." unless @namespace.nil?
          sampled(sample_rate) do
            stat = stat.gsub(Camayoc::DELIMITER,'.')
            msg = "#{prefix}#{stat}:#{delta}|#{type}#{'|@' << sample_rate.to_s if sample_rate < 1}"
            synchronize do
              @socket.send(msg, 0)
            end
          end
        end
    end
  end
end
