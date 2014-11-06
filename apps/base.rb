require 'sinatra/base'

module Api
  # {{{ class Error < StandardError
  class Error < StandardError
    attr_reader :code, :status
    # {{{ def initialize(status, code = nil)
    def initialize(status, code = nil)
      @status = status if status.is_a? Integer
      @code = code if code.is_a? Integer
    end

    # }}}
  end

  # }}}
  # {{{ class Base < Sinatra::Base
  class Base < Sinatra::Base
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    # VALID_PASS_REGEX = /\A.*(?=.{10,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*\z/
    VALID_PASS_REGEX = /\A.*(?=.{6,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*\z/
    
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
    # {{{ before provides: :json do
    before provides: :json do
      keys = [ 'apikey' ]
      unless keys.include? request.env['HTTP_AUTHORIZATION']
        halt 401, { error: 'Invalid API Key' }.to_json
      end
    end

    # }}}
    # {{{ error Api::Error do
    error Api::Error do
      e = env['sinatra.error']
      err = {
        message: e.message
      }
      err[:code] = e.code if e.code
      status e.status ? e.status : 405
      { error: err }.to_json
    end

    # }}}
  end

  # }}}
end
