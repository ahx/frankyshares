require 'rubygems'
require 'sinatra'
require 'action_view'
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'file_cabinet'

before do
  @cabinet = FileCabinet.new(Sinatra.application.options.public + "/files")
end
   
not_found do
  erb :not_found
end 
  
get '/' do
  erb :index
end

post '/' do
  @folder = @cabinet.add_file(params[:file][:tempfile].path, :filename => params[:file][:filename])
  redirect folder_path(@folder)
end

get '/:id/i' do
  @folder = @cabinet.find(params[:id])
  raise Sinatra::NotFound if @folder.nil?
  erb :fileinfo  
end

helpers do
  include Rack::Utils  
  alias_method :h, :escape_html  
  include ActionView::Helpers::DateHelper
  
  # converts an integer to a readable file size
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
  
  def file_path(file)
    file.sub(Sinatra.application.options.public,"")
  end
  
  def folder_path(folder)
    "/#{folder.id}/i"
  end
  
  def folder_url(folder)
    root_url + folder_path(folder)
  end
  
  # returns the base path of this app. FIXME isn't there a shorter/built in way?
  def root_url
    # NOTE there was a problem with request.port, when using sockets (Thin), 
    # so here we are not assembling the url (request.schema + ... + 
    # request.port), but just using a (dirty?) regexp..
    request.url.match(/(^.*\/{2}[^\/]*)/)[1]
  end
end

use_in_file_templates!

__END__

@@ layout
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<link rel="stylesheet" href="/application.css" type="text/css" media="screen" title="colorfull disk" charset="utf-8">
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
  <form action="/" enctype="multipart/form-data" method="post">    
    <p>
      <label for="share_file">File</label>
      <input name="file" size="30" type="file" />        
      <p>The file will be destroyed after two days!</p>
    </p>
    <p>
      <input class="upload_file" name="commit" type="submit" value="Upload the file" />
    </p>  
  </form>


@@ fileinfo
  <h2>
    <a href="<%=h file_path(@folder.file) %>" title="Download this file now!">Download <i><%=h File.basename(@folder.file) %></i> now</a>
  </h2> 
  <div>
    <b>File size:</b>
    <%=h file_size_string File.size(@folder.file) %><br />
    <b>Uploaded at:</b> <%= File.ctime(@folder.file).to_s(:long) %><br />
    <p> 
      This file will be destroyed in <%= time_ago_in_words(File.ctime(@folder.file) + 172800) %> <%# 2 days  %>
    </p>
    <p>
      <a href="mailto:?subject=&body=Hi there! I have uploaded a file for you. You can download it here: <%=h folder_url(@folder) %>" title="email this page">email this page</a>
    </p>  
  </div>  
  <p>
    <a href="/">Share another file</a>
  </p> 
  
@@ not_found
  <h2>File not found</h2>
  <p>Either you got the wrong adress or this file has expired. <br />
    <span class="light-description">(Uploaded files get deleted after two days.)</span></p>
  