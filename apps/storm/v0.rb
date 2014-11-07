require 'orchestrate'
require 'multi_json'
require 'excon'
require 'securerandom'
require 'active_support/all'

module Storm
  class V0 < Storm::Base
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
            error[:status] = 404
            error[:code] = 40400
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
            error[:status] = 404
            error[:code] = 40401
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
          error[:status] = 404
          error[:code] = 40401
          error[:message] = 'Member not found'
        end
      else
        error[:status] = 400
        error[:code] = 40001
        error[:message] = 'Missing parameters'
      end

      unless error[:message].blank?
        raise Storm::Error.new(error[:status], error[:code]), error[:message]
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
        raise Storm::Error.new(422, 42201), 'Email is not valid' unless Storm::VALID_EMAIL_REGEX.match(params[:email])

        # check for type of login
        unless params[:fb_id].blank?
          raise Storm::Error.new(400, 40002), 'Facebook ID is not a number' unless params[:fb_id].numeric?
          params[:password] = SecureRandom.hex
        else
          # check for password strength
          raise Storm::Error.new(422, 42201), 'Password is not valid' unless Storm::VALID_PASS_REGEX.match(params[:password])
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
          raise Storm::Error.new(422, 42202), msg
        end

      else
        raise Storm::Error.new(400, 40001), 'Missing required parameter: email'
      end

      data = member.value
      data[:email] = member.key
      data.delete_if { |key, value| ['password', 'salt'].include? key }
      status 201
      body data.to_json
    end

    # }}}
    # {{{ post '/members/forgot_pass', provides: :json do
    post '/members/forgot_pass', provides: :json do
      raise Storm::Error.new(400, 40001), 'Missing required parameter: email' if params[:email].blank?

      # clean and validate email
      params[:email].strip!
      params[:email].downcase!
      raise Storm::Error.new(422, 42201), 'Email is not valid' unless Storm::VALID_EMAIL_REGEX.match(params[:email])

      begin
        member = @O_APP[:members][params[:email]]
        raise Storm::Error.new(404, 40401), 'Member not found' if member.nil?
        member[:temp_pass] = SecureRandom.hex
        member[:temp_expiry] = Orchestrate::API::Helpers.timestamp(Time.now + 1.day)
        member.save!
      rescue Orchestrate::API::BaseError => e
        raise Storm::Error.new(422, 42202), e.message
      end

      status 200
      response = { 
        success: true,
        fb_login: !member[:fb_id].nil?
      }
      body response.to_json
    end

    # }}}
    # {{{ get '/stores', provides: :json do
    get '/stores', provides: :json do
      # check for required parameters
      raise Storm::Error.new(400, 40001), 'Missing required parameter: latitude' if params[:latitude].blank? || !params[:latitude].numeric?
      raise Storm::Error.new(400, 40002), 'Missing required parameter: longitude' if params[:longitude].blank? || !params[:longitude].numeric?
      
      params[:distance] = '1mi' if params[:distance].blank?
      params[:offset] = 0 if params[:offset].blank? || !params[:offset].numeric?
      params[:limit] = 20 if params[:limit].blank? || !params[:limit].numeric?
      query = "location:NEAR:{lat:#{params[:latitude]} lon:#{params[:longitude]} dist:#{params[:distance]}}"
      options = {
        sort: 'location:distance:asc',
        offset: params[:offset],
        limit: params[:limit]
      }
      response = @O_CLIENT.search(:stores, query, options)

      data = {
        count: response.count,
        total_count: response.total_count
      }
      data[:items] = response.results.collect do |store|
        s = store['value']
        s[:key] = store['path']['key']
        s['_links'] = {
          rewards: "/#{self.class.name.demodulize.downcase}/rewards?store_key=#{s[:key]}",
          points: "/#{self.class.name.demodulize.downcase}/points?store_key=#{s[:key]}&email=",
        }
        s
      end
      
      status 200
      body data.to_json
    end

    # }}}
    # {{{ get '/rewards', provides: :json do
    get '/rewards', provides: :json do
      # check for required parameters
      raise Storm::Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?

      data = []

      begin
        response = @O_CLIENT.get_relations(:stores, params[:store_key], :rewards)
        loop do
          break if response.nil?
          response.results.each do |reward|
            r = reward['value']
            r[:key] = reward['path']['key']
            data << r
          end
          response = response.next_results
        end
      rescue Orchestrate::API::BaseError => e
        case e.class.code
        when 'items_not_found'
          raise Storm::Error.new(404, 40401), e.message
        else
          raise Storm::Error.new(422, 42201), e.message
        end
      end

      data.sort! { |a,b| a['cost'] <=> b['cost'] }
      status 200
      body data.to_json
    end

    # }}}
  end
end
