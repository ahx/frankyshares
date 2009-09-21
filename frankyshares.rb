# encoding: UTF-8

require 'sinatra/base'
# We want rack's edge (>1.0.0) version, because of some crucial fixes for Ruby 1.9
require File.dirname(__FILE__) + '/lib/rack/lib/rack'
require File.dirname(__FILE__) + '/lib/rack/lib/rack/utils'
$LOAD_PATH << File.dirname(__FILE__) + '/lib/chronic_duration/lib'
require 'chronic_duration'
require 'moneta/basic_file' # gem install moneta

# TODO Add a "rake cron" task to delete expired files. Right now, these get only 
# deleted, when the info page ("/foo") is requestet, not the actual file ("/foo/file.txt")

class Frankyshares < Sinatra::Base
  include Rack::Utils

  # Options
  set :root, File.dirname(__FILE__)
  set :time_to_expire, 172800  # Two days
  set :upload_dir, self.public + "/files" # should be considered read-only
  use_in_file_templates!
  enable :static
  
  def self.meta_store
    Moneta::BasicFile.new(:path => File.join(self.root, "meta_store"))
  end
  
  configure do
    FileUtils.mkdir_p(self.upload_dir)
  end
  
  before do
    @meta_store = Frankyshares.meta_store
  end
  
  not_found do
    erb :not_found
  end 
  
  get '/' do
    erb :index
  end

  post '/' do
    if params[:file] # fail silently if empty
      folder = add_file(params[:file][:tempfile].path, params[:file][:filename])      
      redirect folder.sub(File.expand_path(options.upload_dir),"")
    end
    erb :index
  end

  get '/:id' do |key|
    @meta = @meta_store[key]
    unless @meta
      FileUtils.rm_rf(File.join(options.upload_dir, key))
      pass 
    end
    @file = @meta[:file]
    # pass unless @file # File.exist?(@file)
    erb :fileinfo
  end

  # Helper methods...

  def download_path(path)
    path.sub(File.expand_path(options.public),"")
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
  
  def expire_time_in_words(file)
    seconds = File.mtime(file).to_i + options.time_to_expire - Time.now.to_i
    ChronicDuration.output(seconds, :format => :long)
  end
      
  def time_to_expire_in_words
    ChronicDuration.output(options.time_to_expire, :format => :long)
  end
  
  private
  
  def add_file(new_file, new_filename)
    raise("Cannot add file, because it does not exist!") unless new_file && File.size?(new_file)    
    key = generate_new_id(new_filename)
    path = File.join(options.upload_dir, key) 
    # Make folder..
    FileUtils.mkdir_p(path)
    # move file..
    file = File.join(path, new_filename)
    FileUtils.mv(new_file, file)
    # FIXME This might be bad
    FileUtils.chmod(0644, File.join(path, new_filename))
    # save meta
    @meta_store.store(key, {:file => file}, :expires_in => options.time_to_expire)
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
      <p>The file will be destroyed after <%= time_to_expire_in_words %>!</p>
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
    <span class="description">(Uploaded files get deleted after <%= time_to_expire_in_words %>.)</span></p>
  