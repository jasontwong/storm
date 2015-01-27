require 'sinatra/base'
require 'resque'
require 'active_support/all'

module Storm
  class Base < Sinatra::Base
    # {{{ options
    configure do
      redis_url = ENV["REDISCLOUD_URL"] || ENV["OPENREDIS_URL"] || ENV["REDISGREEN_URL"] || ENV["REDISTOGO_URL"]
      uri = URI.parse(redis_url)
      Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      Resque.redis.namespace = "resque:storm"
      Time.zone = 'Central Time (US & Canada)'
    end
    # {{{ dev
    configure :development, :test do
      enable :dump_errors, :logging
      disable :show_exceptions
    end

    # }}}
    # {{{ prod
    configure :production do
      enable :dump_errors
      set :bind, '0.0.0.0'
      set :port, 80
    end

    # }}}
    # }}}
    # {{{ error Storm::Error, provides: :json do
    error Storm::Error, provides: :json do
      e = env['sinatra.error']
      err = {
        message: e.message
      }
      err[:code] = e.code if e.code
      status e.status ? e.status : 405
      { error: err }.to_json
    end

    # }}}
    # {{{ not_found do
    not_found do
      response.headers['Content-Type'] = 'application/json'
      { 
        error: {
          message: 'Invalid endpoint'
        }
      }.to_json
    end

    # }}}
  end

end
