Dir["./lib/**/*.rb"].each {|file| require file }
Dir["./apps/*.rb"].each {|file| require file }

map('/v0') { run Api::V0 }
