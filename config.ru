require_relative "apps/storm"
require 'resque/server'

if ENV['AUTH_PASSWORD']
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == ENV['AUTH_PASSWORD']
  end
end

map('/v0') { run Storm::V0 }
map('/resque') { run Resque::Server.new }
