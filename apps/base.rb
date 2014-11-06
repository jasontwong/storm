require 'sinatra/base'

module Api
  class Base < Sinatra::Base
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
    # {{{ before provides: :json do
    before provides: :json do
      keys = [ 'apikey' ]
      unless keys.include? request.env['HTTP_AUTHORIZATION']
        halt 401, { error: 'Invalid API Key' }.to_json
      end
    end

    # }}}
  end
end
