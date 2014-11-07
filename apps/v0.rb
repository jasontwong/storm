require 'sinatra/base'
require 'orchestrate'
require 'multi_json'
require 'excon'
require 'securerandom'

# {{{ class Object
class Object
  # {{{ def blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  # }}}
end

# }}}
# {{{ class String
class String
  # {{{ def numeric?
  def numeric?
    true if Float(self) rescue false
  end

  # }}}
  # {{{ def blank?
  def blank?
    self !~ /\S/
  end

  # }}}
end

# }}}
module Api
  class V0 < Api::Base
    # {{{ before provides: :json do
    before provides: :json do
      halt 426 if !request.env['HTTP_X_IOS_SDK_VERSION'].nil? && request.env['HTTP_X_IOS_SDK_VERSION'].to_f < 1.7
      halt 426 if !request.env['HTTP_X_ANDROID_SDK_VERSION'].nil? && request.env['HTTP_X_ANDROID_SDK_VERSION'].to_f < 1.7
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
      error = { status: 401 }
      if !params[:fb_id].blank?
        if params[:fb_id].numeric?
          response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
          unless response.results.empty?
            member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
          else
            error[:code] = 40100
            error[:message] = 'Facebook ID not found'
          end
        else
          error[:status] = 400
          error[:code] = 40002
          error[:message] = 'Facebook ID is not a number'
        end
      elsif !params[:member_id].blank?
        if params[:member_id].numeric?
          response = @O_CLIENT.search(:members, "old_id:#{params[:member_id]}")
          unless response.results.empty?
            member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
          else
            error[:code] = 40101
            error[:message] = 'Member not found'
          end
        else
          error[:status] = 400
          error[:code] = 40003
          error[:message] = 'Member ID is not a number'
        end
      elsif !params[:email].blank? && !params[:password].blank?
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
        error[:status] = 400
        error[:code] = 40001
        error[:message] = 'Missing parameters'
      end

      unless error[:message].blank?
        raise Api::Error.new(error[:status], error[:code]), error[:message]
      else
        data = member.value
        data[:email] = member.key
        data.delete_if { |key, value| ['password', 'salt'].include? key }
        status 200
        body data.to_json
      end
    end

    # }}}
    # {{{ post '/members/register', provides: :json do
    post '/members/register', provides: :json do
      unless params[:email].blank?
        # clean and validate email
        params[:email].strip!
        params[:email].downcase!
        raise Api::Error.new(422, 42201), 'Email is not valid' unless Api::Base::VALID_EMAIL_REGEX.match(params[:email])

        # check for type of login
        unless params[:fb_id].blank?
          raise Api::Error.new(400, 40002), 'Facebook ID is not a number' unless params[:fb_id].numeric?
          params[:password] = SecureRandom.hex
        else
          # check for password strength
          raise Api::Error.new(422, 42201), 'Password is not valid' unless Api::Base::VALID_PASS_REGEX.match(params[:password])
        end

        # validate attributes key
        unless params[:attributes].blank?
          unless params[:attributes].is_a? Hash
            begin
              params[:attributes] = JSON.parse(params[:attributes], symbolize_names: true)
            rescue JSON::ParseError => e
              params[:attributes] = {}
            end
          end
        else
          params[:attributes] = {}
        end

        # param data is valid
        member_data = {
          salt: SecureRandom.hex,
          active: true,
          fb_id: params[:fb_id],
          attributes: params[:attributes]
        }

        password = Digest::SHA256.new
        password.update params[:password] + member_data[:salt]
        member_data[:password] = password.hexdigest

        begin
          member = @O_APP[:members].set(params[:email], member_data, false)
        rescue Orchestrate::API::BaseError => e
          case e.class.code
          when 'item_already_present'
            msg = 'Member email already exists'
          else
            msg = e.message
          end
          raise Api::Error.new(422, 42202), msg
        end

      else
        raise Api::Error.new(400, 40001), 'Missing required parameter: email'
      end

      data = member.value
      data[:email] = member.key
      data.delete_if { |key, value| ['password', 'salt'].include? key }
      status 200
      body data.to_json
    end

    # }}}
  end
end
