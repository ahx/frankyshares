require 'app'

{
    # FIXME I don't know, what this run option means
    :run => false,
    :environment => :production
}.each { |k, v| Frankyshares.set(k, v) }

run Frankyshares