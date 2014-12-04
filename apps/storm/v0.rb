require 'orchestrate'
require 'multi_json'
require 'excon'
require 'securerandom'
require 'active_support/all'
require 'aws-sdk'
require 'mandrill'

module Storm
  class V0 < Base
    # {{{ before do
    before do
      halt 426 if !request.env['HTTP_X_IOS_SDK_VERSION'].nil? && request.env['HTTP_X_IOS_SDK_VERSION'].to_f < 2.0
      halt 426 if !request.env['HTTP_X_ANDROID_SDK_VERSION'].nil? && request.env['HTTP_X_ANDROID_SDK_VERSION'].to_f < 2.0
      @O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      allow = false
      allow = request.env['HTTP_AUTHORIZATION'] == DEV_KEY unless settings.production?
      unless allow
        key = @O_APP[:api_keys][request.env['HTTP_AUTHORIZATION']]
        if key.nil?
          halt 401, {
            'Content-Type' => 'application/json'
          }, { 
            error: {
              message: 'Invalid API Key'
            }
          }.to_json
        end
      end
      AWS.config(
        :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
        :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
      )
      @MANDRILL = Mandrill::API.new ENV['MANDRILL_APIKEY']
    end

    # }}}
    # {{{ post '/members/login', provides: :json do
    post '/members/login', provides: :json do
      if !params[:fb_id].blank?
        # FB login
        if params[:fb_id].numeric?
          response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
          unless response.results.empty?
            member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
          else
            raise Error.new(404, 40400), 'Facebook ID not found'
          end
        else
          raise Error.new(400, 40002), 'Facebook ID is not a number'
        end
      elsif !params[:member_id].blank?
        # Login from old version of app
        if params[:member_id].numeric?
          response = @O_CLIENT.search(:members, "old_id:#{params[:member_id]}")
          unless response.results.empty?
            member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
          else
            raise Error.new(404, 40401), 'Member not found'
          end
        else
          raise Error.new(400, 40003), 'Member ID is not a number'
        end
      elsif !params[:email].blank? && !params[:password].blank?
        # Email/Pass login
        member = @O_APP[:members][params[:email]]
        if member
          password = Digest::SHA256.new
          password.update params[:password] + member[:salt]
          old_pass = Digest::SHA256.new
          old_pass.update params[:password]
          dhash = Digest::SHA256.new
          dhash.update old_pass.hexdigest + member[:salt]

          if member[:password] == password.hexdigest
            @O_CLIENT.post_event(:members, member.key, :login, { ip: request.ip })
          elsif member[:password] == dhash.hexdigest
            member[:password] = password.hexdigest
            member.save!
            @O_CLIENT.post_event(:members, member.key, :login, { ip: request.ip })
          else
            raise Error.new(401, 40102), 'Password incorrect'
          end
        else
          raise Error.new(404, 40401), 'Member not found'
        end
      else
        raise Error.new(400, 40001), 'Missing parameters'
      end
      
      raise Error.new(404, 40402), 'Member found but inactive' unless member[:active]

      data = member.value
      data[:email] = member.key
      data.delete_if { |key, value| ['password', 'salt'].include? key }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ post '/members/register', provides: :json do
    post '/members/register', provides: :json do
      unless params[:email].blank?
        # clean and validate email
        params[:email].strip!
        params[:email].downcase!
        raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(params[:email])

        member_data = {
          salt: SecureRandom.hex,
          active: true,
          verified: false
        }

        # check for type of login
        unless params[:fb_id].blank?
          raise Error.new(400, 40002), 'Facebook ID is not a number' unless params[:fb_id].numeric?
          response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
          raise Error.new(422, 42205), 'Facebook ID already in use' unless response.results.empty?
          params[:password] = SecureRandom.hex
          member_data[:fb_id] = params[:fb_id].to_i
          member_data[:verifed] = true
        else
          # check for password strength
          raise Error.new(422, 42204), 'Password is not valid' unless !params[:password].blank? && params[:password].length >= 6
        end

        # validate attributes key
        unless params[:attributes].blank?
          unless params[:attributes].is_a? Hash
            begin
              params[:attributes] = JSON.parse(params[:attributes], symbolize_names: true)
            rescue JSON::ParserError => e
              params[:attributes] = {}
            end
          end
        else
          params[:attributes] = {}
        end

        # param data is valid
        member_data[:attributes] = params[:attributes]
        password = Digest::SHA256.new
        password.update params[:password] + member_data[:salt]
        member_data[:password] = password.hexdigest

        begin
          member = @O_APP[:members].set(params[:email], member_data, false)
          unless member_data[:verified]
            template_name = 'email-verification'
            template_content = []
            message = {
              to: [{
                email: params[:email],
                type: 'to'
              }],
              headers: {
                "Reply-To" => 'info@getyella.com'
              },
              important: true,
              track_opens: true,
              track_clicks: true,
              url_strip_qs: true,
              tags: ['email-verification'],
              google_analytics_domains: ['getyella.com'],
            }
            async = true
            result = @MANDRILL.messages.send_template(template_name, template_content, message, async)
          end
        rescue Orchestrate::API::BaseError => e
          case e.class.code
          when 'item_already_present'
            raise Error.new(422, 42202), 'Member email already exists'
          else
            raise Error.new(422, 42203), e.message
          end
        rescue Mandrill::Error => e
          raise Error.new(422, 42204), e.message
        end

      else
        raise Error.new(400, 40001), 'Missing required parameter: email'
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
        template_name = "forgot-pw"
        template_content = []
        message = {
          to: [{
            email: params[:email],
            type: 'to'
          }],
          headers: {
            "Reply-To" => 'info@getyella.com'
          },
          important: true,
          track_opens: true,
          track_clicks: true,
          url_strip_qs: true,
          merge_vars: [{
            rcpt: member.key,
            vars: [{
              name: "temp_pass",
              content: member[:temp_pass],
            }]
          }],
          tags: ['password-reset'],
          google_analytics_domains: ['getyella.com'],
        }
        async = false
        result = @MANDRILL.messages.send_template(template_name, template_content, message, async)
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42202), e.message
      rescue Mandrill::Error => e
        raise Error.new(422, 42203), e.message
      end

      status 200
      response = { 
        success: true,
        fb_login: !member[:fb_id].blank?
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
        begin
          attributes = JSON.parse(params[:attributes]) if params[:attributes].is_a? String
          member[:attributes].merge!(attributes)
          member.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42203), "Unable to save attributes properly"
        rescue JSON::ParserError => e
          raise Error.new(400, 40002), "Unable to parse attributes properly"
        end
      end

      unless params[:fb_id].blank?
        raise Error.new(400, 40001), 'Facebook ID is not a number' unless params[:fb_id].numeric?
        response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
        raise Error.new(422, 42205), 'Facebook ID already in use' unless response.results.empty?
        begin
          member[:fb_id] = params[:fb_id].to_i
          member.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save Facebook ID properly"
        end
      end

      unless params[:password].blank?
        raise Error.new(422, 42205), 'Password is not valid' unless params[:password].length >= 6
        begin
          password = Digest::SHA256.new
          password.update params[:password] + member[:salt]
          member[:password] = password.hexdigest
          member.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42206), "Unable to save password properly"
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

      company = store.relations[:company].first
      raise Error.new(404, 40405), 'Company not found' if company.nil?

      begin
        # get the member's points for this store
        query = "company_key:#{company.key} AND member_key:#{member.key}"
        options = {
          limit: 1
        }
        response = @O_CLIENT.search(:points, query, options)
        unless response.count > 1
          # TODO
          # There is a bug that allowed two sets of points notify admin
        end
        # we couldn't find points that are associated with this key/member combination
        raise Error.new(404, 40406), "Member does not have any points at this company" if response.results.empty?
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end

      data = response.results.first['value']
      data.delete_if { |key, value| ['member_key', 'company_key'].include? key }
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

      company = store.relations[:company].first
      raise Error.new(404, 40405), 'Company not found' if company.nil?

      begin
        # get the member's points for this store
        query = "company_key:#{company.key} AND member_key:#{member.key}"
        options = {
          limit: 1
        }
        response = @O_CLIENT.search(:points, query, options)
        if response.count > 1
          # TODO
          # There is a bug that allowed two sets of points notify admin
        end

        points_keys = Helpers.modify_points(member, company, params[:points].to_i)

        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-generate-member-stats')
        queue.send_message(
          'Points modified',
          message_attributes: {
            "member_key" => {
              "string_value" => member.key,
              "data_type" => "String",
            }
          }
        )

        if params[:points].to_i > 0
          event = {
            points: params[:points].to_i,
            member_key: member.key,
            company_key: company.key,
            store_key: store.key
          }
          queue = sqs.queues.named('storm-generate-events')
          queue.send_message(
            { keys: points_keys, data: event }.to_json,
            message_attributes: {
              "collection" => {
                "string_value" => 'points',
                "data_type" => "String",
              },
              "event_name" => {
                "string_value" => 'earned',
                "data_type" => "String",
              },
            }
          )
        end
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

      company = store.relations[:company].first
      raise Error.new(404, 40403), 'Company not found' if company.nil?

      begin
        data = []
        response = @O_CLIENT.get_relations(:companies, company.key, :rewards)
        loop do
          response.results.each do |reward|
            r = reward['value']
            r[:key] = reward['path']['key']
            data << r
          end
          response = response.next_results
          break if response.nil?
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

      company = store.relations[:company].first
      raise Error.new(404, 40405), 'Company not found' if company.nil?

      found = false
      response = @O_CLIENT.get_relations(:companies, company.key, :rewards)
      loop do
        response.results.each do |listing|
          if params[:reward_key] == listing['path']['key']
            found = true
            break
          end
        end
        break if response.nil? || found
      end
      raise Error.new(404, 40406), 'Reward does not match company' unless found

      begin
        # get the member's points for this store
        query = "company_key:#{company.key} AND member_key:#{member.key}"
        options = {
          limit: 1
        }
        response = @O_CLIENT.search(:points, query, options)
        unless response.total_count.nil?
          # TODO
          # There is a bug that allowed two sets of points notify admin
        end
        # we couldn't find points that are associated with this key/member combination
        raise Error.new(422, 42202), "Not enough points to redeem reward" if response.results.empty?
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
              Helpers.modify_points(member, company, reward[:cost] * -1)
              # {{{ member stat generation
              sqs = AWS::SQS.new
              queue = sqs.queues.named('storm-generate-member-stats')
              queue.send_message(
                'Points modified',
                message_attributes: {
                  "member_key" => {
                    "string_value" => member.key,
                    "data_type" => "String",
                  }
                }
              )

              # }}}
              # {{{ events
              queue = sqs.queues.named('storm-generate-events')
              queue.send_message(
                { keys: [reward.key], data: rw_data }.to_json,
                message_attributes: {
                  "collection" => {
                    "string_value" => 'rewards',
                    "data_type" => "String",
                  },
                  "event_name" => {
                    "string_value" => 'redeems',
                    "data_type" => "String",
                  },
                }
              )

              # }}}
              # {{{ relations
              relations = [{
                from_collection: 'stores',
                from_key: store.key,
                from_name: 'redeems',
                to_collection: 'redeems',
                to_key: redeem_key
              },{
                from_collection: 'members',
                from_key: member.key,
                from_name: 'redeems',
                to_collection: 'redeems',
                to_key: redeem_key
              }]
              queue = sqs.queues.named('storm-generate-relations')
              queue.send_message(
                relations.to_json,
              )

              # }}}
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
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      status 201
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
    # {{{ get '/stores/:key', provides: :json do
    get '/stores/:key', provides: :json do
      # validate params
      store = @O_APP[:stores][params[:key]]
      raise Error.new(404, 40401), "Store not found" if store.nil?
      raise Error.new(404, 40402), 'Store found but not active' unless store[:active]

      data = store.value
      data[:key] = store.key
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
          s_data['_links'] = {
            store: "/#{self.class.name.demodulize.downcase}/stores/#{s_data['store_key']}",
          }
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
        data['_links'] = {
          store: "/#{self.class.name.demodulize.downcase}/stores/#{data[:store_key]}",
        }
        # TODO
        # Is there a faster way to do this?!?!
        # @O_CLIENT.put_relation(:codes, code.key, :member_surveys, :member_surveys, data[:key])
        # @O_CLIENT.put_relation(:stores, store.key, :member_surveys, :member_surveys, data[:key])
        # @O_CLIENT.put_relation(:member_surveys, data[:key], :code, :codes, code.key)
        # @O_CLIENT.put_relation(:member_surveys, data[:key], :store, :stores, store.key)
        # @O_CLIENT.put_relation(:member_surveys, data[:key], :member, :members, member.key)
        # @O_CLIENT.put_relation(:members, member.key, :surveys, :member_surveys, data[:key])
        # {{{ relations
        relations = [{
          from_collection: 'codes',
          from_key: code.key,
          from_name: 'member_surveys',
          to_collection: 'member_surveys',
          to_key: data[:key]
        },{
          from_collection: 'members',
          from_key: member.key,
          from_name: 'surveys',
          to_collection: 'member_surveys',
          to_key: data[:key]
        },{
          from_collection: 'stores',
          from_key: store.key,
          from_name: 'member_surveys',
          to_collection: 'member_surveys',
          to_key: data[:key]
        },{
          from_collection: 'member_surveys',
          from_key: data[:key],
          from_name: 'member',
          to_collection: 'members',
          to_key: member.key
        },{
          from_collection: 'member_surveys',
          from_key: data[:key],
          from_name: 'store',
          to_collection: 'stores',
          to_key: store.key
        },{
          from_collection: 'member_surveys',
          from_key: data[:key],
          from_name: 'code',
          to_collection: 'codes',
          to_key: code.key
        }]
        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-generate-relations')
        queue.send_message(
          relations.to_json,
        )

        # }}}
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
      data['_links'] = {
        store: "/#{self.class.name.demodulize.downcase}/stores/#{survey[:store_key]}",
      }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/surveys/:key', provides: :json do
    patch '/surveys/:key', provides: :json do
      # validate params
      survey = @O_APP[:member_surveys][params[:key]]
      raise Error.new(404, 40401), "Survey not found" if survey.nil?
      raise Error.new(422, 42205), "Survey is already completed" if !survey[:completed].blank? && survey[:completed] == true

      # TODO
      # Figure out a better way to handle answers, large payload
      unless params[:answers].blank?
        begin
          if params[:answers].is_a? String
            answers = JSON.parse(params[:answers], symbolize_names: true)
          else
            answers = params[:answers]
          end
          survey[:answers] = answers.collect do |answer|
            answer[:answer] = answer[:answer].to_f unless answer[:type] == 'switch'
            answer
          end
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42202), "Unable to save answers properly"
        rescue JSON::ParserError => e
          raise Error.new(400, 40001), "Unable to parse answers properly"
        end
      end

      unless params[:comments].blank?
        begin
          survey[:comments] = params[:comments]
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42203), "Unable to save comments properly"
        end
      end

      if !params[:nps_score].blank? && params[:nps_score].numeric?
        begin
          survey[:nps_score] = params[:nps_score].to_i
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save nps_score properly"
        end
      end

      if !params[:completed].blank? && (params[:completed] == 'true' || params[:completed] == true || (params[:completed].numeric? && params[:completed].to_i == 1))
        begin
          survey[:completed] = true
          survey[:completed_at] = Orchestrate::API::Helpers.timestamp(Time.now)
          survey.save!
          points_keys = Helpers.modify_points(member, company, survey[:worth])

          sqs = AWS::SQS.new
          queue = sqs.queues.named('storm-generate-member-stats')
          queue.send_message(
            'Points modified',
            message_attributes: {
              "member_key" => {
                "string_value" => member.key,
                "data_type" => "String",
              }
            }
          )

          event = {
            points: survey[:worth],
            member_key: member.key,
            company_key: company.key,
            store_key: store.key
          }
          queue = sqs.queues.named('storm-generate-events')
          queue.send_message(
            { keys: points_keys, data: event }.to_json,
            message_attributes: {
              "collection" => {
                "string_value" => 'points',
                "data_type" => "String",
              },
              "event_name" => {
                "string_value" => 'earned',
                "data_type" => "String",
              },
            }
          )
          # TODO
          # Send out notification to store owners
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42201), "Unable to save completed properly"
        end
      end

      status 204
    end

    # }}}
  end
end
