require 'sinatra/base'
require 'orchestrate'
require 'multi_json'
require 'excon'
require 'securerandom'

module Api
  class V0 < Api::Base
    # {{{ before provides: :json do
    before provides: :json do
      error 426 if !request.env['HTTP_X_IOS_SDK_VERSION'].nil? && request.env['HTTP_X_IOS_SDK_VERSION'].to_f < 1.7
      error 426 if !request.env['HTTP_X_ANDROID_SDK_VERSION'].nil? && request.env['HTTP_X_ANDROID_SDK_VERSION'].to_f < 1.7
      @O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
    end

    # }}}
    # {{{ post '/members/login', provides: :json do
    post '/members/login', provides: :json do
      error = {}
      if params[:fb_id]
        response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
        unless response.results.empty?
          member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
        else
          error[:code] = 40100
          error[:message] = 'Facebook ID not found'
        end
      elsif params[:member_id]
        response = @O_CLIENT.search(:members, "old_id:#{params[:member_id]}")
        unless response.results.empty?
          member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
        else
          error[:code] = 40101
          error[:message] = 'Member not found'
        end
      elsif params[:email] && params[:password]
        member = @O_APP[:members][params[:email]]
        if member
          password = Digest::SHA256.new
          password.update params[:password] + member[:salt]

          if member[:password] == password.hexdigest
            @O_CLIENT.post_event(:members, member.key, :login, { ip: request.ip })
          else
            error[:code] = 40102
            error[:message] = 'Password incorrect'
          end
        else
          error[:code] = 40101
          error[:message] = 'Member not found'
        end
      else
        error[:code] = 40001
        error[:message] = 'Missing parameters'
        halt 400, { 
          error: error
        }.to_json
      end

      if error[:message]
        halt 401, { 
          error: error
        }.to_json
      else
        status 200
        data = member.value
        data[:email] = member.key
        data.delete_if { |key, value| ['password', 'salt'].include? key }
        body data.to_json
      end
    end

    # }}}
  end
end
