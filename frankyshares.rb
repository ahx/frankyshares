require 'sinatra/base'
require File.dirname(__FILE__) + '/lib/file_cabinet'
$LOAD_PATH << File.dirname(__FILE__) + '/lib/chronic_duration/lib'
require 'chronic_duration'

class Frankyshares < Sinatra::Base
  include Rack::Utils  
  alias_method :h, :escape_html

  # Options
  set :root, File.dirname(__FILE__)
  set :time_to_expire, 172800  # Two days
  set :disk_quota, nil         # Set total space available in BYTES
  
  # Settings
  use_in_file_templates!
  enable :static

  before do
    @cabinet = FileCabinet.new(options.public + "/files", :quota => options.disk_quota)
  end
   
  not_found do
    erb :not_found
  end 
  
  get '/' do
    erb :index
  end

  post '/' do
    begin
      @folder = @cabinet.add_file(params[:file][:tempfile].path, :filename => params[:file][:filename])      
      redirect folder_path(@folder)
    rescue FileCabinet::FileDoesNotExist
      erb :index # '/'  # fail silently
    rescue FileCabinet::QuotaExceeded
      erb :quota_exceeded 
    end    
  end

  get '/:id' do
    @folder = @cabinet.find(params[:id])
    raise Sinatra::NotFound if @folder.nil?
    erb :fileinfo
  end


  # Helper methods...

  # Takes a number and returns a readable file size
  def file_size_string(fs)
    # n cuts off all decimal places after the second
    n = lambda{|f| f.to_s[/.*\..{0,2}/] }     
    if fs < 1024
      "#{n.call(fs)} Bytes"
    elsif fs <= 1024**2
      "#{n.call(fs/1024.0)} KBytes"
    elsif fs <= 1024**3
      "#{n.call(fs/1024.0**2)} MBytes"
    elsif fs <= 1024**4
      "#{n.call(fs/1024.0**3)} GBytes"
    end
  end
  
  def expire_time_in_words
    ChronicDuration.output(options.time_to_expire, :format => :long)
  end
  
  def time_until_expire_in_words(folder)    
    deadline = File.mtime(folder.file).to_i + options.time_to_expire
    ChronicDuration.output(deadline - Time.now.to_i, :format => :long)
  end

  def file_path(file)
    file.sub(File.expand_path(self.class.public),"")
  end

  def folder_path(folder)
    "/#{folder.id}"
  end

  def folder_url(folder)
    root_url + folder_path(folder)
  end

  # returns the base path of this app. FIXME isn't there a shorter/built in way?
  def root_url
    # NOTE there was a problem with request.port, when using sockets (Thin), 
    # so here we are not assembling the url (request.schema + ... + 
    # request.port), but just using a (dirty?) regexp..
    @request.url.match(/(^.*\/{2}[^\/]*)/)[1]
  end

end

# Run it
Frankyshares.run! if $0 == __FILE__

__END__

@@ layout
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<link rel="stylesheet" href="/app.css" type="text/css" media="screen" title="colorfull disk" charset="utf-8">
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <title>I Haz Filesharez!</title>
</head>
<body>
<div id="page">
  <div id="site-title"><a href="/" title="Startpage"><img src="/disk.png" width="383" height="105" alt="Exploding disk" /></a></div>  
  <%= yield  %>
</div>
</body>
</html>


@@ index
  <h2>Share a file</h2>
  <form id="upload_form" action="/" enctype="multipart/form-data" method="post">    
    <p>
      <label for="file">File</label>
      <input name="file" size="30" type="file" />      
      <p>The file will be destroyed after <%= expire_time_in_words %>!</p>
    </p>
    <p>
      <input class="upload_file" name="upload" type="submit" value="Share this file now" />
    </p>  
  </form>


@@ fileinfo
  <h2>
    <a href="<%=h file_path(@folder.file) %>" title="Download this file now!">Download <i><%=h File.basename(@folder.file) %></i> now</a>
  </h2> 
  <div>
    <b>File size:</b>
    <%=h file_size_string(File.size(@folder.file)) %><br />
    <b>Uploaded at:</b> <%= File.ctime(@folder.file).to_s %><br />
    <p> 
      This file will be destroyed in <%= time_until_expire_in_words(@folder) %>
    </p>
    <p>
      <a href="mailto:?subject=&body=Hi there! I have uploaded a file for you. You can download it here: <%=h folder_url(@folder) %>" title="email this page">email this page</a>
    </p>  
  </div>  
  <p>
    <a href="/">Share another file</a>
  </p> 

@@ quota_exceeded
  <h2>Sorry, i can't take anymore!</h2>  
  <p>There is not enough space available to save your file right now. <br /> 
  Maybe you want to try uploading the file again in a few hours, after some old files have been deleted automatically.</p>

@@ not_found
  <h2>File not found</h2>
  <p>Either you got the wrong adress or this file has expired. <br />
    <span class="light-description">(Uploaded files get deleted after <%= expire_time_in_words %>.)</span></p>
  