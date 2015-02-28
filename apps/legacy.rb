require "rubygems"
require "bundler/setup"
require 'sinatra/base'

class Legacy < Sinatra::Base
  # {{{ options
  # {{{ dev
  configure :development, :test do
    enable :dump_errors, :logging
    disable :show_exceptions
  end

  # }}}
  # {{{ prod
  configure :production do
    set :bind, '0.0.0.0'
    set :port, 80
  end

  # }}}
  # }}}
  # {{{ post '/ios/check_version', provides: :json do
  post '/ios/check_version', provides: :json do
    status 200
    data = { success: false }
    body data.to_json
  end
  # }}}
end
