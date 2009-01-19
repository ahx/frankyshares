require 'sinatra'

{   
    :run => false,
    :environment => :production,

    # FIXME This should not be necessary, but i have to do this, if i am 
    # using Thin (instead of just 'ruby app.rb' (mongrel?)). Sinatra Bug?
    :public => File.expand_path(".") + "/public"
}.each { |k, v| Sinatra::Default.set(k, v) }

require 'app'
run Sinatra::Application