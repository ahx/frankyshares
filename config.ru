require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'app'
run Sinatra.application