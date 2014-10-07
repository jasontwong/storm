require 'sinatra/base'
require 'orchestrate'

module Api
  class V0 < Api::Base
    # {{{ before xhr: true, provides: :json do
    before xhr: true, provides: :json do
      error 426 if !request.env['HTTP_X_IOS_SDK_VERSION'].nil? && request.env['HTTP_X_IOS_SDK_VERSION'].to_f < 1.7
      error 426 if !request.env['HTTP_X_ANDROID_SDK_VERSION'].nil? && request.env['HTTP_X_ANDROID_SDK_VERSION'].to_f < 1.7
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
