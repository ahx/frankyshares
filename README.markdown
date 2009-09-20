Frankyshares
===============================================

This is a simple rapidshare-like webapp.

What you can do with it
-----------------------
* upload a file
* see a info-page with filename and size
* download the file


Download and run it
-------------------
Clone git repository
    git clone git://github.com/ahaller/frankyshares.git
    
Don't forget to checkout submodules
    cd frankyshares
    git submodule update --init
    
Run it

    rackup
or
    ruby frankyshares.rb

There is a 'rake cron' task to delete old files, which you should run regularly:
    rake cron

The app just works on Ruby 1.9. To run the tests you need the test-unit gem though.

Options
-------
You can set the expire time in seconds, default is two days:
    Frankyshares.:time_to_expire = 36000 # 10hours (default is two days)

Enjoy.
