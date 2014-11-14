require 'orchestrate'
require 'excon'
require 'aws-sdk'
require 'rake/benchmark' if ENV['RACK_ENV'] != 'production'
AWS.config(
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
)
Dir.glob('lib/tasks/**/*.rake').each { |r| load r}
