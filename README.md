Overview
========
Camayoc is a flexible way to keep track of application stats and events. 
Inspired by various logging frameworks (especially Log4r) it makes it easy to 
send stats information to multiple destinations via the use of Handlers. Right 
out of the box, it supports sending stats to the following:

* A [statsd daemon](https://github.com/etsy/statsd/) for ridiculously easy [Graphite](http://graphite.wikidot.com/) stats
* An in-memory hash for in-process stats
* A logger or IO stream
* Redis (EXPERIMENTAL - you'll need the [redis gem](https://github.com/ezmobius/redis-rb))

Philosophy
----------
Keeping track of what goes on in your application is critical. But even 
critical things get ignored if they're hard (believe me, we know). Camayoc's aim 
is to make logging events and capturing stats easy:

* Collecting this data should take just one line of code
* All data collection should be fire-and-forget with no error handling required
* Organizing stats and events should be easy
* There should be essentially no performance cost to collecting this data

Events vs Stats
---------------
In general, events are things that happen in your application that you care 
about. There are two ways to keep track of events:

* Keep summary stats about event occurances around (counts, etc)
* Keep a detailed record of events that occur in a some sort of log or collection

Through its use of flexible handlers, Camayoc makes it possilbe to do one or 
both of these through a single simple interface.

Examples
==========
Here's all it takes to fire stats to statsd. 

    require 'camayoc'
    # Grab a stats instance
    stats = Camayoc["my_app"]
    # Add a handler for statsd
    stats.add(Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234))
    
    # later in your app
    def do_some_stuff
      # Do some stuff
      Camayoc["my_app"].increment("did_stuff")
    end
    
Your stat will be sent to statsd with the name "my_app.did_stuff". See the 
statsd docs for more information about how that gets translated into Graphite.

Namespaces
----------
Many logging frameworks support the concept of namespaced logs that "extend" 
other logs. This makes it easy to log messages from different areas of your 
app and stay sane. Camayoc does this as well. 

Let's say you have a service within your app where you want to store some timing 
data.

    stats = Camayoc["my_app"]
    stats.add(Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234))

    class AwesomeService
      def be_awesome
        start_time = Time.now.to_f
        # Be, you know, awesome
        ms = ((Time.now_to_f - start_time) * 1000).round
        Camayoc["my_app:awesome_service"].timing("awesome_duration",ms)
      end
    end
    
This will automatically create a timing metric in graphite via statsd called 
"my_app.awesome_service.awesome_duration". It does this by using the statsd 
handler already configured for its "my_app" parent. Now, about handlers...

Handlers
--------
Just like loggers can have multiple outputters, you might want to send your 
stats to different places.

    app_stats = Camayoc["my_app"]
    app_stats.add(Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234))
    
    foo_stats = Camayoc["my_app:foo"]
    foo_stats.add(Camayoc::Handlers::Redis.new(:host=>"localhost"))
    
    app_stats.count("bar",1000) # Stats end up in statsd
    
    foo_stats.count("baz",150) # Stats go to redis *and* statsd
    
Filters
-------
Sometimes you may want to send only certain stats to certain places.

    app_stats = Camayoc["my_app"]
    app_stats.add(Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234))
    
    foo_stats = Camayoc["my_app:foo"]
    foo_stats.add(Camayoc::Handlers::Redis.new(:host=>"localhost"),:when=>/baz/)
    
    foo_stats.increment("baz",1000) #Stats go to redis and statsd
    foo_stats.increment("bar",5)    #Stats only go to statsd, not redis
    
There are other options as well like :if and :unless that take Procs that can 
be executed to determine if a metric should be sent to the specified handler.
See Camayoc::Handlers::Filter for more.

Event Logging
-------------
Sometimes you may want to keep a detailed log of events that occur instead of 
summarizing then via counts. Below is an example of logging event data in a 
space-delimited format to an IO stream:

    event_log = Camayoc["events"]
    fmt = Proc.new do |event| 
      ([event.ns_stat, Time.now.to_i] + Array(event.value)).join(" ") 
    end
    event_log.add(Camayoc::Handlers::IO.new(STDOUT,:formatter=>fmt))

    event_log.event("foo",["bar","baz"])

This will produce the following on stdout:

    events:foo 1321564751 bar baz

Available Handlers
==================
Statsd
------
Class: Camayoc::Handlers::Statsd

This handler sends data to the statd daemon for use in graphite. If you can get 
graphite and statsd going, then you'll get pretty graphs.

This handler does not support logging details about events since this isn't 
really what statsd and graphite are for. Any calls to the event method will be 
treated as count stats when sent to statsd.

Memory
------
Class: Camayoc::Handlers::Memory

Stores counts and timing data in an in-memory hash. This might be handy for 
storing some temporary in-process stats.

If you use this handler for event logging, data will be stored in an in-memory 
array with a configurable max size. If that size is exceeded, older events will 
be evicted to make room for new events.

Logger
------
Class: Camayoc::Handlers::Logger

Writes out stat values and a timestamp to a logger instance for later analysis.
The format and method called on the logger can be controlled by constructor 
arguments. See the class for details.

This handler is best for event logging, especially when combined with a custom 
formatter.

IO
--
Class: Camayoc::Handlers::IO

Writes out stats values and a timestamp to some stream of your choice. See 
class for configuration details.

Another good event logging handler.

Redis (Experimental)
--------------------
Class: Camayoc::Handlers::Redis (require "camayoc/handlers/redis" first) 

The redis gem is required to use this handler. This is a very, very simple 
implementation that stores some data in redis. It is in no way a full-fledged 
time-based stats system. It does make it easy to collect some simple counts and 
some timing data. You can easily retrieve the stored data from redis by using 
the #get method.

This handler does not currently support event logging.


Implementing a Handler
======================

v0.2+ Incompatibility Notice
----------------------------
As of Version 0.2.0, handlers must implement an event method. In 0.1.0, 
handlers had to implement count and timing methods. Now handlers are encouraged 
to dispatch events as described below.

Implementation Example
---------------------- 
Let's say you want to implement your own handler, perhaps to MongoDB. Handlers 
just need to respond to a simple interface. See Camayoc::Handlers::StatEvent 
for info on the argument to the event method.

    class SomeHandler
      def event(evt)
        case evt.type
          when :count   then handle_count(evt)  # do something with a count stat
          when :timing  then handle_timing(evt) # do something with a timing stat
          when :generic then handle_other(evt)  # do something with a generic event
      end
    end

If you were writing a MongoDB handler, the above might increment a value in 
a collection on :count and :timing and store raw data to a collection for 
:generic events.

If you write a handler and would like it included in Camayoc, please fork 
and send a pull request and we'll get it integrated in.

Acknowledgements
================
* The basic structure of Camayoc owes a lot of [Log4r](http://log4r.rubyforge.org/)
* The socket code for the Statsd handler is a modification of [reinh](https://github.com/reinh)'s [statsd](https://github.com/reinh/statsd)
