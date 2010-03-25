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
    
Install/Check bundled gems (versions locked)
    bundle install

Run it using the config.ru
The app just works on Ruby 1.9.

Settings
-------
You can set the expire time in seconds, default is two days:
    Frankyshares.:time_to_expire = 36000 # 10hours (default is two days)


Dependencies
------------
See Gemfile

Enjoy.
