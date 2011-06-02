Overview
========
Camayoc is a flexible way to keep track of application stats. Inspired by 
various logging frameworks (especially Log4r) it makes it easy to send stats 
information to multiple destinations via the use of Handlers. Right out of the 
box, it supports sending stats to the following:

* A [statsd daemon](https://github.com/etsy/statsd/) for ridiculously easy [Graphite](http://graphite.wikidot.com/) stats
* An in-memory hash for in-process stats
* Redis (you'll need the [redis gem](https://github.com/ezmobius/redis-rb))

Philosophy
----------
Application stats are critical. But even critical things get ignored if they're 
hard (believe me, we know). Stats should be easy:

* Collecting stats should take just one line of code
* All stat collection should be fire-and-forget with no error handling required
* Organizing stats should be easy
* There should be essentially no performance cost to collecting stats

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

Available Handlers
==================
Statsd
------
Class: Camayoc::Handlers::Statsd

This handler sends data to the statd daemon for use in graphite. If you can get 
graphite and statsd going, then you'll get pretty graphs.

Redis
-----
Class: Camayoc::Handlers::Redis    

This is a very, very simple implementation that stores some data in redis. It 
is in no way a full-fledged time-based stats system. It does make it easy to 
collect some simple counts and some timing data. You can easily retrieve the 
stored data from redis by using the #get method.

Memory
------
Class: Camayoc::Handlers::Memory

Stores counts and timing data in an in-memory hash. This might be handy for 
storing some temporary in-process stats.

Implmenting a Handler
=====================
Let's say you want to implement your own handler, pehaps to MongoDB. Handlers 
just need to respond to a simple interface. See Camayoc::Handlers::StatEvent 
for info on the argument to the two methods.

    class SomeHandler
      def count(stat_event)
        # Do something
      end
      
      def timing(stat_event)
        # Do something
      end
    end

If you write a handler and would like it included in Camayoc, please fork 
and send a pull request and we'll get it integrated in.

Acknowledgements
================
* The basic structure of Camayoc owes a lot of [Log4r](http://log4r.rubyforge.org/)
* The socket code for the Statsd handler is a modification of [reinh](https://github.com/reinh)'s [statsd](https://github.com/reinh/statsd)
