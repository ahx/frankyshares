Frankyshares
===============================================

This is a simple rapidshare-like webapp.

== What you can do with it
* upload a file
* see a info-page with filename and size
* download the file

== Install it
* checkout submodules with "git submodule init; git submodule update"
* There is a 'rake cron' task to delete old files, which you should run regularly

== Run it
Use these commands:
    rackup
or
    ruby frankyshares.rb
or like every other Sinatra / Rack-App

== Options
You can set the expire time in seconds, default is two days:
    Frankyshares.expire_time = 172800   # two days


Enjoy.


== TODO
context does not support Ruby1.9's Tes::Unit right now, so the unit-tests are non-functional with Ruby1.9 right now.

Maybe add some anti-flooding mechanism.
