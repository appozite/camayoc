Overview
========
Camayoc is a flexible way to keep track of application stats. Inspired by 
various logging frameworks (especially Log4r) it makes it easy to send stats 
information to multiple destinations via the use of Handlers. Right out of the 
box, it supports sending stats to the following:

* A statsd daemon for ridiculously easy Graphite stats
* An in-memory hash for in-process stats
* A log file for later aggregation
* Redis (you'll need the redis gem)

Philosophy
----------
* Collecting stats should take just one line of code
* All stat collection should be fire-and-forget with no error handling required
* Organizing stats should be easy
* There should be essentially no performance cost to collecting stats

Examples
==========
Here's all it takes to fire stats to statsd. 

    require 'camayoc'
    stats = Camayoc["my_app"]
    stats.add(Camayoc::Handlers::Statsd.new(:host=>"localhost",:port=>1234))
    
    # later in your app
    def do_some_stuff
      # Do some stuff
      Camayoc["my_app"].increment("did_stuff")
    end
    
Your stats will show up in graphite under "stats.my_app.did_stuff"

Namespaces
----------
Many logging frameworks support the concept of namespaced logs that "extend" 
other logs. This makes it easy to log messages from different areas of your 
app and stay sane. Camayoc does this as well. 

Let's say you have a service within your app where you want to store some timing 
data.

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
    
Acknowledgements
================
* The basic structure of Camayoc owes a lot of [Log4r](http://log4r.rubyforge.org/)
* The socket code for the Statsd handler is a modification of [reinh](https://github.com/reinh)'s [statsd](https://github.com/reinh/statsd)
