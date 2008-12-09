require 'rubygems'
require 'sinatra'
$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'share'

get '/' do
  # Shows splash screen and upload form
  erb :index
end

post '/' do
  # TODO save file and redirect to show page
end

get '/:id/i' do
  # TODO Show file info page
  erb :fileinfo
end

get '/files/:id' do
  # TODO send file? - Should not be managed by nginx. Use /public-folder and let the webserver (nginx) send the file!
end

use_in_file_templates!

__END__

@@ layout
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<link rel="stylesheet" href="/stylesheets/application.css" type="text/css" media="screen" title="colorfull disk" charset="utf-8">
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <title>I Haz Filesharez!</title>
</head>
<body>
<div id="page">
  <div id="site-title"><a href="/" title="Startpage"><img src="/images/disk.png" width="383" height="105" alt="Exploding disk" /></a></div>  
  <%= yield  %>
</div>
</body>
</html>


@@ index
<h2>Share a file</h2>
<form action="/" class="new_share" enctype="multipart/form-data" id="new_share" method="post">    
  <p>
    <label for="share_file">File</label>
    <input id="share_file" name="file" size="30" type="file" />
    <br />
    The file will be destroyed after two days!
  </p>
  <p>
    <input class="upload_file" name="commit" type="submit" value="Upload the file" />
  </p>  
</form>


@@ fileinfo
"TODO i am the fileinfo view"