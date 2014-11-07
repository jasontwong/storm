require 'sinatra/base'

module Storm
  class Base < Sinatra::Base
    # {{{ options
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
    # {{{ before do
    before do
      keys = [ 'apikey' ]
      unless keys.include? request.env['HTTP_AUTHORIZATION']
        halt 401, {
          'Content-Type' => 'application/json'
        }, { 
          error: {
            message: 'Invalid API Key'
          }
        }.to_json
      end
    end

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
