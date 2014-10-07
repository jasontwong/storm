require 'sinatra/base'

module Api
  class Base < Sinatra::Base
    set(:xhr) { |xhr| condition { request.xhr? == xhr } }
    # {{{ options
    # {{{ dev
    configure :development, :test do
      enable :dump_errors, :logging
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
    # {{{ before xhr: true, provides: :json do
    before xhr: true, provides: :json do
      keys = [ 'apikey' ]
      error 401 unless keys.include? request.env['HTTP_AUTHORIZATION']
    end

    # }}}
  end
end
