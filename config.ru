require 'sinatra'

{
    :run => false,
    :environment => :production
}.each { |k, v| Sinatra::Default.set(k, v) }

require 'app'
run Sinatra::Application