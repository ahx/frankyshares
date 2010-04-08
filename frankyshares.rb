# encoding: UTF-8
begin
  require File.expand_path('.bundle/environment', __FILE__)
rescue LoadError
  require "bundler"
  Bundler.setup # FIXME Load only :default gems here?
end

require 'sinatra/base'
require 'chronic_duration'

class Frankyshares < Sinatra::Base
  include Rack::Utils

  # Settings
  set :root, File.dirname(__FILE__)
  set :time_to_expire, 172800  # Two days
  set :upload_dir, self.public + "/files" # should be considered read-only
  enable :inline_templates
  enable :static
    
  configure do
    FileUtils.mkdir_p(self.upload_dir)
  end
  
  not_found do
    status 404
    erb :not_found
  end 
  
  get '/' do
    erb :index
  end

  post '/' do
    if params[:file] # fail silently if empty
      folder = add_file(params[:file][:tempfile].path, params[:file][:filename])      
      redirect folder.sub(File.expand_path(settings.upload_dir),"")
    end
    erb :index
  end

  get '/:id' do |key|
    @file = Dir.glob(File.join(settings.upload_dir, key, '*')).first    
    not_found unless @file && File.file?(@file)
    FileUtils.rm_rf(File.dirname(@file)) && not_found if Frankyshares.expired?(@file)
    erb :fileinfo
  end

  # Class methods that we use in the Rake task
  def self.expired?(file)
    seconds_to_expire(file) < 0
  end
    
  def self.seconds_to_expire(file)
    File.mtime(file).to_i + time_to_expire - Time.now.to_i
  end

  # Helper methods...
  
  def download_path(path)
    path.sub(File.expand_path(settings.public),"")
  end

  # Takes a number (Bytes) and returns a readable file size
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
  
  def seconds_in_words(seconds)
    ChronicDuration.output(seconds, :format => :long)
  end
  
  def expire_time_in_words(file)    
    seconds_in_words(self.class.seconds_to_expire(file))
  end
  
  private
  
  def add_file(new_file, new_filename)
    raise("Cannot add file, because it does not exist!") unless new_file && File.size?(new_file)    
    key = generate_new_id(new_filename)
    path = File.join(settings.upload_dir, key) 
    # Make folder..
    FileUtils.mkdir_p(path)
    # move file..
    file = File.join(path, new_filename)
    FileUtils.mv(new_file, file)
    # FIXME This might be bad
    FileUtils.chmod(0644, File.join(path, new_filename))
    path
  end
  
  def find_first_file_in(path)
    Dir.glob("#{path}/[^.]*").first    
  end
  
  def generate_new_id(filename)
    # FIXME I don't like randomness
    "#{Time.now.to_i}#{rand(9)}".to_i.to_s(36)
  end
end

# Run it
Frankyshares.run! if $0 == __FILE__

__END__

@@ layout
<!DOCTYPE html>
<html>
<head>
  <link rel="icon" type="image/png" href="/favicon.png" />  
  <link rel="stylesheet" href="/app.css" type="text/css" media="screen" title="colorfull disk" charset="utf-8">
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
      <p>The file will be destroyed after <%= seconds_in_words(settings.time_to_expire) %>!</p>
    </p>
    <p>
      <input class="upload_file" name="upload" type="submit" value="Share this file now" />
    </p>  
  </form>


@@ fileinfo
  <h2>
    <a href="<%=escape_html download_path(@file) %>" title="Download this file now!">Download <i><%=escape_html File.basename(@file) %></i> now</a>
  </h2> 
  <div>
    <b>File size:</b>
    <%= file_size_string(File.size(@file)) %><br />
    <b>Uploaded at:</b> <%= File.ctime(@file).to_s %><br />
    <p> 
      This file will be destroyed in <%= expire_time_in_words(@file) %>
    </p>
    <p>
      <a href="mailto:?subject=&body=Hi there! I have uploaded a file for you. You can download it here: <%=escape_html request.url %>" title="email this page">email this page</a>
    </p>  
  </div>  
  <p>
    <a href="/">Share another file</a>
  </p> 

@@ not_found
  <h2>File not found</h2>
  <p>Either you got the wrong adress or this file has expired. <br />
    <span class="description">(Files get deleted after <%= seconds_in_words(settings.time_to_expire) %>.)</span></p>
  