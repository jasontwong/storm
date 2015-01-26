require "rubygems"
require "bundler/setup"
require 'orchestrate'
require 'excon'
require 'aws-sdk'
require 'thread'
require 'rake/benchmark' if ENV['RACK_ENV'] == 'development'
require_relative "lib/jobs"
require 'resque'
require 'resque/tasks'

AWS.config(
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
)
Dir.glob('lib/tasks/**/*.rake').each { |r| load r}

redis_url = ENV["REDISCLOUD_URL"] || ENV["OPENREDIS_URL"] || ENV["REDISGREEN_URL"] || ENV["REDISTOGO_URL"]
uri = URI.parse(redis_url)
Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
Resque.redis.namespace = "resque:storm"

class ThreadPool
  def initialize(size)
    @size = size
    @jobs = Queue.new
    @pool = Array.new(@size) do |i|
      Thread.new do
        Thread.current[:id] = i
        catch(:exit) do
          loop do
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end
  def schedule(*args, &block)
    @jobs << [block, args]
  end
  def shutdown
    @size.times do
      schedule { throw :exit }
    end
    @pool.map(&:join)
  end
end

task "resque:setup" do
  ENV['QUEUE'] ||= '*'
end
