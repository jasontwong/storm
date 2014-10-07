require 'sinatra/base'
require 'orchestrate'

module Api
  class V0 < Api::Base
    # {{{ before xhr: true, provides: :json do
    before xhr: true, provides: :json do
      @O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY'])
      @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
    end

    # }}}
    # {{{ get '/companies', xhr: true, provides: :json do
    get '/companies', xhr: true, provides: :json do
      {}.to_json
    end

    # }}}
  end
end
