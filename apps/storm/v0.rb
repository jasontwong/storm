require 'orchestrate'
require 'multi_json'
require 'excon'
require 'securerandom'
require 'active_support/all'

module Storm
  class V0 < Base
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
        # FB login
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
        # Login from old version of app
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
        # Email/Pass login
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
      
      unless member[:active]
        error[:status] = 404
        error[:code] = 40402
        error[:message] = 'Member found but inactive'
      end

      unless error[:message].blank?
        raise Error.new(error[:status], error[:code]), error[:message]
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
        raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(params[:email])

        # check for type of login
        unless params[:fb_id].blank?
          raise Error.new(400, 40002), 'Facebook ID is not a number' unless params[:fb_id].numeric?
          params[:password] = SecureRandom.hex
        else
          # check for password strength
          raise Error.new(422, 42201), 'Password is not valid' unless params[:password].length >= 6
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
          fb_id: params[:fb_id].to_i,
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
            raise Error.new(422, 42202), 'Member email already exists'
          else
            raise Error.new(422, 42203), e.message
          end
        end

      else
        raise Error.new(400, 40001), 'Missing required parameter: email'
      end

      # TODO
      # Send welcome/verification email to member
      
      data = member.value
      data[:email] = member.key
      data.delete_if { |key, value| ['password', 'salt'].include? key }
      status 201
      body data.to_json
    end

    # }}}
    # {{{ post '/members/forgot_pass', provides: :json do
    post '/members/forgot_pass', provides: :json do
      raise Error.new(400, 40001), 'Missing required parameter: email' if params[:email].blank?

      # clean and validate email
      params[:email].strip!
      params[:email].downcase!
      raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(params[:email])

      # validate params
      member = @O_APP[:members][params[:email]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      begin
        member[:temp_pass] = SecureRandom.hex
        member[:temp_expiry] = Orchestrate::API::Helpers.timestamp(Time.now + 1.day)
        member.save!
        # TODO
        # Send notification to member
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42202), e.message
      end

      status 200
      response = { 
        success: true,
        fb_login: !member[:fb_id].nil?
      }
      body response.to_json
    end

    # }}}
    # {{{ get '/members/:key', provides: :json do
    get '/members/:key', provides: :json do
      # validate params
      member = @O_APP[:members][params[:key]]
      raise Error.new(404, 40401), "Member email not found" if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      data = member.value
      data[:email] = member.key
      data.delete_if { |key, value| ['password', 'salt'].include? key }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/members/:key', provides: :json do
    patch '/members/:key', provides: :json do
      # validate params
      member = @O_APP[:members][params[:key]]
      raise Error.new(404, 40401), "Member email not found" if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]
      
      unless params[:email].blank?
        # clean and validate email
        params[:email].strip!
        params[:email].downcase!
        raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(params[:email])

        begin
          member2 = @O_APP[:members].set(params[:email], member.value, false)
          member.destroy!
          member = member2
        rescue Orchestrate::API::BaseError => e
          case e.class.code
          when 'item_already_present'
            msg = 'Email already in use'
          else
            msg = e.message
          end
          raise Error.new(422, 42202), msg
        end
      end

      unless params[:attributes].blank?
        attributes = JSON.parse(params[:attributes]) if params[:attributes].is_a? String
        member[:attributes].merge!(attributes)
        begin
          member.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42203), "Unable to save attributes properly"
        end
      end

      unless params[:fb_id].blank?
        raise Error.new(400, 40001), 'Facebook ID is not a number' unless params[:fb_id].numeric?
        member[:fb_id] = params[:fb_id].to_i
        begin
          member.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save Facebook ID properly"
        end
      end

      status 204
    end

    # }}}
    # {{{ get '/points', provides: :json do
    get '/points', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: email' if params[:email].blank?

      # validate params
      member = @O_APP[:members][params[:email]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40403), 'Member found but not active' unless member[:active]

      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40402), 'Store not found' if store.nil?
      raise Error.new(404, 40404), 'Store found but not active' unless store[:active]

      begin
        # get the member's points for this store
        query = "store_key:#{store.key} AND member_key:#{member.key}"
        options = {
          limit: 1
        }
        response = @O_CLIENT.search(:points, query, options)
        unless response.total_count.nil?
          # TODO
          # There is a bug that allowed two sets of points notify admin
        end
        if response.results.empty?
          # we couldn't find points that are associated with this key/member combination
          point_data = {
            current: 0,
            total: 0,
            member_key: member.key,
            store_key: store.key
          }
          begin
            @O_CLIENT.post(:points, point_data)
          rescue Orchestrate::API::BaseError => e
            # unable to redeem reward
            raise Error.new(422, 42201), e.message
          end
        else
          point = Orchestrate::KeyValue.from_listing(@O_APP[:points], response.results.first, response)
        end
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      data = point.value
      data.delete_if { |key, value| ['member_key', 'store_key'].include? key }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/points', provides: :json do
    patch '/points', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: email' if params[:email].blank?
      raise Error.new(400, 40003), 'Missing required parameter: points' if params[:points].blank? || !params[:points].numeric?

      # validate params
      member = @O_APP[:members][params[:email]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40403), 'Member found but not active' unless member[:active]

      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40402), 'Store not found' if store.nil?
      raise Error.new(404, 40404), 'Store found but not active' unless store[:active]

      begin
        # get the member's points for this store
        query = "store_key:#{store.key} AND member_key:#{member.key}"
        options = {
          limit: 1
        }
        response = @O_CLIENT.search(:points, query, options)
        if response.count > 1
          # TODO
          # There is a bug that allowed two sets of points notify admin
        end

        Helpers.modify_points(member, store, params[:points].to_i)

      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      status 204
    end

    # }}}
    # {{{ get '/rewards', provides: :json do
    get '/rewards', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?

      # validate params
      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40401), 'Store not found' if store.nil?
      raise Error.new(404, 40402), 'Store found but not active' unless store[:active]

      begin
        data = []
        store.relations[:rewards].each do |reward|
          r = reward.value
          r[:key] = reward.key
          data << r
        end
      rescue Orchestrate::API::BaseError => e
        case e.class.code
        when 'items_not_found'
          raise Error.new(404, 40403), e.message
        else
          raise Error.new(422, 42201), e.message
        end
      end

      data.sort! { |a,b| a['cost'] <=> b['cost'] }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ post '/rewards', provides: :json do
    post '/rewards', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: email' if params[:email].blank?
      raise Error.new(400, 40002), 'Missing required parameter: reward_key' if params[:reward_key].blank?
      raise Error.new(400, 40003), 'Missing required parameter: store_key' if params[:store_key].blank?

      # validate params
      member = @O_APP[:members][params[:email]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40404), 'Member found but not active' unless member[:active]

      reward = @O_APP[:rewards][params[:reward_key]]
      raise Error.new(404, 40402), 'Reward not found' if reward.nil?

      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40403), 'Store not found' if store.nil?
      raise Error.new(404, 40405), 'Store found but not active' unless store[:active]

      begin
        # get the member's points for this store
        query = "store_key:#{store.key} AND member_key:#{member.key}"
        options = {
          limit: 1
        }
        response = @O_CLIENT.search(:points, query, options)
        unless response.total_count.nil?
          # TODO
          # There is a bug that allowed two sets of points notify admin
        end
        if response.results.empty?
          # we couldn't find points that are associated with this key/member combination
          raise Error.new(422, 42202), "Not enough points to redeem reward"
        else
          points = Orchestrate::KeyValue.from_listing(@O_APP[:points], response.results.first, response)
          if reward[:cost] < points[:current]
            begin
              # redeem reward
              rw_data = {
                title: reward[:title],
                cost: reward[:cost],
                member_key: member.key,
                store_key: store.key
              }
              response = @O_CLIENT.post(:redeems, rw_data)
              uri = URI(response.location)
              path = uri.path.split("/")[2..-1]
              redeem_key = path[1]
              begin
                Helpers.modify_points(member, store, reward[:cost] * -1)
                @O_CLIENT.put_relation(:members, member.key, :redeems, :redeems, redeem_key)
                @O_CLIENT.put_relation(:stores, store.key, :redeems, :redeems, redeem_key)
              rescue Orchestrate::API::BaseError => e
                # unable to subtract points
                @O_CLIENT.delete(:redeems, redeem_key, response.ref)
                raise Error.new(422, 42204), "Reward not redeemed"
              end
            rescue Orchestrate::API::BaseError => e
              # unable to redeem reward
              raise Error.new(422, 42201), e.message
            end
          else
            # not enough points to redeem
            raise Error.new(422, 42202), "Not enough points to redeem reward"
          end
        end
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      status 200
      data = { success: true }
      body data.to_json
    end

    # }}}
    # {{{ get '/stores', provides: :json do
    get '/stores', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: latitude' if params[:latitude].blank? || !params[:latitude].numeric?
      raise Error.new(400, 40002), 'Missing required parameter: longitude' if params[:longitude].blank? || !params[:longitude].numeric?
      
      params[:distance] = '1mi' if params[:distance].blank?
      params[:offset] = 0 if params[:offset].blank? || !params[:offset].numeric?
      params[:limit] = 20 if params[:limit].blank? || !params[:limit].numeric?
      query = "location:NEAR:{lat:#{params[:latitude]} lon:#{params[:longitude]} dist:#{params[:distance]}} AND active:true"
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
    # {{{ get '/surveys', provides: :json do
    get '/surveys', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: email' if params[:email].blank?

      # validate params
      member = @O_APP[:members][params[:email]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      limit = 20 if params[:limit].blank? || !params[:limit].numeric?
      offset = 0 if params[:offset].blank? || !params[:offset].numeric?

      begin
        now = Time.now
        max = Orchestrate::API::Helpers.timestamp(now)
        min = Orchestrate::API::Helpers.timestamp(now - SURVEY_EXP_DAYS.days)
        query = "NOT completed:true AND created_at:[#{min} TO #{max}] AND member_key:#{member.key}"
        options = {
          limit: limit,
          offset: offset,
          sort: 'created_at:desc'
        }
        response = @O_CLIENT.search(:member_surveys, query, options)
        data = {
          count: response.count,
          total_count: response.total_count || response.count,
          items: []
        }
        response.results.each do |survey|
          s_data = survey['value']
          s_data[:key] = survey['path']['key']
          data[:items] << s_data
        end
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end
      
      status 200
      body data.to_json
    end

    # }}}
    # {{{ post '/surveys', provides: :json do
    post '/surveys', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: email' if params[:email].blank?
      raise Error.new(400, 40002), 'Missing required parameter: major' if params[:major].blank? || !params[:major].numeric?
      raise Error.new(400, 40003), 'Missing required parameter: minor' if params[:minor].blank? || !params[:minor].numeric?

      # validate params
      member = @O_APP[:members][params[:email]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      begin
        query = "major:#{params[:major]} AND minor:#{params[:minor]}"
        options = {
          limit: 1,
        }
        response = @O_CLIENT.search(:codes, query, options)
        raise Error.new(404, 40401), "Beacon not found" if response.count == 0
        unless response.total_count.nil?
          # TODO
          # There's more than one code with that major/minor. Broken.
        end
        code = Orchestrate::KeyValue.from_listing(@O_APP[:codes], response.results.first, response)
        store = code.relations[:store].first
        type = store.relations[:type].first
        data = {
          answers: type[:questions],
          worth: 5,
          member_key: member.key,
          store_key: store.key,
          created_at: Orchestrate::API::Helpers.timestamp(Time.now),
        }
        response = @O_CLIENT.post(:member_surveys, data)
        uri = URI(response.location)
        path = uri.path.split("/")[2..-1]
        data[:key] = path[1]
        @O_CLIENT.put_relation(:codes, code.key, :member_surveys, :member_surveys, data[:key])
        @O_CLIENT.put_relation(:stores, store.key, :member_surveys, :member_surveys, data[:key])
        @O_CLIENT.put_relation(:member_surveys, data[:key], :code, :codes, code.key)
        @O_CLIENT.put_relation(:member_surveys, data[:key], :store, :stores, store.key)
        @O_CLIENT.put_relation(:member_surveys, data[:key], :member, :members, member.key)
        @O_CLIENT.put_relation(:members, member.key, :surveys, :member_surveys, data[:key])
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end
      
      status 200
      body data.to_json
    end

    # }}}
    # {{{ get '/surveys/:key', provides: :json do
    get '/surveys/:key', provides: :json do
      # validate params
      survey = @O_APP[:member_surveys][params[:key]]
      raise Error.new(404, 40401), "Survey not found" if survey.nil?

      data = survey.value
      data[:key] = survey.key
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/surveys/:key', provides: :json do
    patch '/surveys/:key', provides: :json do
      # validate params
      survey = @O_APP[:member_surveys][params[:key]]
      raise Error.new(404, 40401), "Survey not found" if survey.nil?

      unless params[:completed].blank?
        if params[:completed] == 'true'
          begin
            survey[:completed] = true
            survey[:completed_at] = Orchestrate::API::Helpers.timestamp(Time.now)
            survey.save!
          rescue Orchestrate::API::BaseError => e
            raise Error.new(422, 42201), "Unable to save completed properly"
          end
        end
      end

      unless params[:answers].blank?
        begin
          answers = JSON.parse(params[:answers], symbolize_names: true) if params[:answers].is_a? String
          survey[:answers] = answers.collect do |answer|
            answer[:answer] = answer[:answer].to_f unless answer[:type] == 'switch'
            answer
          end
          survey.save!
        rescue Orchestrate::API::BaseError, JSON::ParseError => e
          raise Error.new(422, 42203), "Unable to save answers properly"
        end
      end

      unless params[:comments].blank?
        begin
          survey[:comments] = params[:comments]
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save comments properly"
        end
      end

      unless params[:nps_score].blank?
        begin
          survey[:nps_score] = params[:nps_score].to_i
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42205), "Unable to save nps_score properly"
        end
      end

      status 204
    end

    # }}}
  end
end
