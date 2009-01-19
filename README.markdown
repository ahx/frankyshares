Frankyshares
===============================================

This is a simple rapidshare-like sinatra app, which does not use a database. 
This is mostly written for educating purpose.

== You can
* upload a file
* see a info-page with filename and size
* download the file ...

== Inner workings
The app consists of two parts:
* a FileCabin class, that manages the files-folder to find and save files
* and the Sinatra app, that provides a web interface. 


There is a bash-script that should delete old uploaded files. This could be used for a cron-job or the like. 


Enjoy.
