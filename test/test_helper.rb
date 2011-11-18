require 'rubygems'
require 'test/unit'
require 'mocha'

$: << File.join(File.dirname(__FILE__),"..","lib")
require 'camayoc'

module EventTestHelper

  def self.included(test)
    test.extend(ClassMethods)
  end

  module ClassMethods
    # Generates methods and populates:
    # * +@event_type+ :: +:count+, +:timing+ or +:generic+
    # * +@event_method+ :: method for Stats:
    #                      +:count+, +:timing+, or +:event+
    def with_event_types(name,event_types=[:count,:timing,:generic],&block)
      Array(event_types).each do |event_type|
        define_method("#{name}_with_#{event_type}") do
          @event_type = event_type
          @event_method = case event_type
            when :count, :timing then event_type
            else :event
          end
          instance_eval(&block)
        end
      end
    end
  end

  def stat_event_match(*args)
    template = Camayoc::StatEvent.new(*args)
    Proc.new do |event|
      event.type == template.type &&
        event.source == template.source &&
        event.stat == template.stat &&
        event.value == template.value &&
        event.options == template.options
    end
  end

end
