require "rubygems"
require "bundler/setup"
require 'orchestrate'
require 'excon'
require 'thread'
require 'rake/benchmark' if ENV['RACK_ENV'] == 'development'
require_relative "lib/jobs"
require 'resque'
require 'resque/tasks'
require 'mandrill'
require 'active_support/all'

Time.zone = 'Central Time (US & Canada)'
Dir.glob('lib/tasks/**/*.rake').each { |r| load r}

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

@O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
  conn.adapter :excon
end
@O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
  conn.adapter :excon
end

task "resque:setup" do
  redis_url = ENV["REDISCLOUD_URL"] || ENV["OPENREDIS_URL"] || ENV["REDISGREEN_URL"] || ENV["REDISTOGO_URL"]
  Resque.redis = Redis.new(url: redis_url)
  Resque.redis.namespace = "resque:storm"
  Resque.workers.map &:unregister_worker
  ENV['QUEUE'] ||= '*'
end
