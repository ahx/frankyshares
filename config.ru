require 'frankyshares'

{ 
  :environment => :development
}.each { |k, v| Frankyshares.set(k, v) }

run Frankyshares
