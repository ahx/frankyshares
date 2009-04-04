Frankyshares
===============================================

This is a simple rapidshare-like webapp.

What you can do with it
-----------------------
* upload a file
* see a info-page with filename and size
* download the file


Install it
----------
Checkout submodules with 
    git submodule update --init


Run it
------
Use one of these commands:
    rackup
or
    ruby frankyshares.rb
or do it like you would with every other Sinatra / Rack-App
There is a 'rake cron' task to delete old files, which you should run regularly!:
    rake cron

The app just works on Ruby 1.9. To run the tests you need the test-unit gem though.

Options
-------
You can set the expire time in seconds, default is two days:
    Frankyshares.:time_to_expire = 36000 # 10hours (default is two days)

As a (naive) anti-flooding mechanism, you can specify a maximum size of your storage, which will get checked on each write:
    Frankyshares.disk_quota = 1024  # Maximum of 1GByte  (default is no limit)

Enjoy.
