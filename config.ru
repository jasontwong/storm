require_relative "apps/storm"
require 'resque/server'

AUTH_PASSWORD = "ISByH8rVGh1xDQXbYjYRyt6LA" 
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

map('/v0') { run Storm::V0 }
map('/resque') { run Resque::Server.new }
