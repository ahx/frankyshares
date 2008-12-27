require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  
  # FIXME This should not be necessary, but i have to do this, if i am 
  # using Thin (instead of just 'ruby app.rb' (mongrel?)). Sinatra Bug?
  :public => File.expand_path(".") + "/public"
)

require 'app'
run Sinatra.application