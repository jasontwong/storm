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
        if key.nil? || request.env['HTTP_AUTHORIZATION'].nil?
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
      @MANDRILL = Mandrill::API.new ENV['MANDRILL_API_KEY']
    end

    # }}}
    # members
    # {{{ post '/members/login', provides: :json do
    post '/members/login', provides: :json do
      if !params[:fb_id].blank?
        # FB login
        raise Error.new(400, 40002), 'Facebook ID is not a number' unless params[:fb_id].numeric?

        response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
        raise Error.new(404, 40400), 'Facebook ID not found' if response.results.empty?

        member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
      elsif !params[:member_id].blank?
        # Login from old version of app
        raise Error.new(400, 40003), 'Member ID is not a number' if params[:member_id].numeric?

        response = @O_CLIENT.search(:members, "old_id:#{params[:member_id]}")
        raise Error.new(404, 40401), 'Member not found' if response.results.empty?

        member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
      elsif !params[:email].blank? && !params[:password].blank?
        # Email/Pass login
        response = @O_CLIENT.search(:members, "email:#{params[:email]}")
        raise Error.new(404, 40401), 'Member not found' if response.results.empty?

        member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
        password = Digest::SHA256.new
        password.update params[:password] + member[:salt]
        old_pass = Digest::SHA256.new
        old_pass.update params[:password]
        dhash = Digest::SHA256.new
        dhash.update old_pass.hexdigest + member[:salt]
        if member[:password] == dhash.hexdigest
          # reverting double hash to single hash
          member[:password] = password.hexdigest
          member.save!
        else
          raise Error.new(401, 40102), 'Password incorrect' unless member[:password] == password.hexdigest
        end
      else
        raise Error.new(400, 40001), 'Missing parameters'
      end
      
      raise Error.new(404, 40402), 'Member found but inactive' unless member[:active]

      @O_CLIENT.post_event(:members, member.key, :login, { ip: request.ip })
      data = member.value
      data[:key] = member.key
      data.delete_if { |k, v| ['password', 'salt'].include? k }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ post '/members/register', provides: :json do
    post '/members/register', provides: :json do
      # clean and validate email
      raise Error.new(400, 40001), 'Missing required parameter: email' unless params[:email].blank?

      member_data = {
        email: params[:email].downcase.strip,
        salt: SecureRandom.hex,
        active: true,
        stats: { 
          points: {},
          rewards: {},
          stores: {},
          surveys: {}
        }
      }
      raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(member_data[:email])

      response = @O_CLIENT.search(:members, "email:#{member_data[:email]}")
      raise Error.new(422, 42202), 'Email already exists' unless response.results.empty?

      # check for type of login
      unless params[:fb_id].blank?
        raise Error.new(400, 40002), 'Facebook ID is not a number' unless params[:fb_id].numeric?

        response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]}")
        raise Error.new(422, 42205), 'Facebook ID already in use' unless response.results.empty?

        params[:password] = SecureRandom.hex
        member_data[:fb_id] = params[:fb_id].to_i
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

      begin
        member_data[:attributes] = params[:attributes]
        password = Digest::SHA256.new
        password.update params[:password] + member_data[:salt]
        member_data[:password] = password.hexdigest
        member = @O_APP[:members].create(member_data)
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      data = member.value
      data[:key] = member.key
      data.delete_if { |key, value| ['password', 'salt'].include? key }
      status 201
      body data.to_json
    end

    # }}}
    # {{{ post '/members/forgot_pass', provides: :json do
    post '/members/forgot_pass', provides: :json do
      # clean and validate email
      raise Error.new(400, 40001), 'Missing required parameter: email' if params[:email].blank?

      email = params[:email].downcase.strip
      raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(email)

      response = @O_CLIENT.search(:members, "email:#{email}")
      raise Error.new(404, 40401), 'Member not found' if response.results.empty?

      member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]
      # {{{ send out email
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
          from_email: "hello@getyella.com",
          headers: {
            "Reply-To" => 'hello@getyella.com'
          },
          important: true,
          track_opens: true,
          track_clicks: true,
          url_strip_qs: true,
          merge_vars: [{
            rcpt: member[:email],
            vars: [{
              name: "pass_reset_url",
              content: "http://www.getyella.com/pass_reset?email=#{member[:email]}&temp_pass=#{member[:temp_pass]}",
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

      # }}}
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
      member = @O_APP[:members][params[:key]]
      raise Error.new(404, 40401), "Member not found" if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      data = member.value
      data[:key] = member.key
      data.delete_if { |k, v| ['password', 'salt'].include? k }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/members/:key', provides: :json do
    patch '/members/:key', provides: :json do
      # validate params
      member = @O_APP[:members][params[:key]]
      raise Error.new(404, 40401), "Member not found" if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]
      # {{{ update email
      unless params[:email].blank?
        email = params[:email].downcase.strip
        raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(:email)

        response = @O_CLIENT.search(:members, "email:#{email} AND NOT key:#{member.key}")
        raise Error.new(422, 42206), 'Email already in use' unless response.results.empty?

        begin
          member.replace('email', email).update
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42202), msg
        end
      end

      # }}}
      # {{{ update attributes
      unless params[:attributes].blank?
        begin
          attributes = JSON.parse(params[:attributes]) if params[:attributes].is_a? String
          member.replace('attributes', attributes.merge!(member[:attributes])).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42203), "Unable to save attributes properly"
        rescue JSON::ParserError => e
          raise Error.new(400, 40002), "Unable to parse attributes properly"
        end
      end

      # }}}
      # {{{ update fb_id
      unless params[:fb_id].blank?
        raise Error.new(400, 40001), 'Facebook ID is not a number' unless params[:fb_id].numeric?

        response = @O_CLIENT.search(:members, "fb_id:#{params[:fb_id]} AND NOT key:#{member.key}")
        raise Error.new(422, 42205), 'Facebook ID already in use' unless response.results.empty?

        begin
          member.replace('fb_id', params[:fb_id].to_i).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save Facebook ID properly"
        end
      end

      # }}}
      # {{{ update password
      unless params[:password].blank?
        raise Error.new(422, 42205), 'Password is not valid' unless params[:password].length >= 6
        begin
          password = Digest::SHA256.new
          password.update params[:password] + member[:salt]
          member.replace('password', password.hexdigest).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42206), "Unable to save password properly"
        end
      end

      # }}}
      status 204
    end

    # }}}
    # {{{ get '/members/:key/places', provides: :json do
    get '/members/:key/places', provides: :json do
      # validate params
      member = @O_APP[:members][params[:key]]
      raise Error.new(404, 40401), "Member not found" if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      data = []
      places = @O_APP[:member_places][params[:key]]
      data = places['visited'] unless places.nil?
      status 200
      body data.to_json
    end

    # }}}
    # points
    # {{{ get '/points', provides: :json do
    get '/points', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: member_key' if params[:member_key].blank?

      # validate params
      member = @O_APP[:members][params[:member_key]]
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
      data.delete_if { |k, v| ['member_key', 'company_key'].include? k }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/points', provides: :json do
    patch '/points', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: member_key' if params[:member_key].blank?
      raise Error.new(400, 40003), 'Missing required parameter: points' if params[:points].blank? || !params[:points].numeric?

      # validate params
      member = @O_APP[:members][params[:member_key]]
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
        # {{{ generate member stats
        queue = sqs.queues.named('storm-generate-member-stats')
        queue.send_message(
          'Points modified',
          message_attributes: {
            "member_key" => {
              "string_value" => member.key,
              "data_type" => "String",
            },
            "store_key" => {
              "string_value" => store.key,
              "data_type" => "String",
            }
          }
        )
        
        # }}}
        # {{{ generate events
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

        # }}}
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      status 204
    end

    # }}}
    # rewards
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
      # {{{ validate parameters
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if params[:member_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: reward_key' if params[:reward_key].blank?
      raise Error.new(400, 40003), 'Missing required parameter: store_key' if params[:store_key].blank?

      member = @O_APP[:members][params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40404), 'Member found but not active' unless member[:active]

      reward = @O_APP[:rewards][params[:reward_key]]
      raise Error.new(404, 40402), 'Reward not found' if reward.nil?
      raise Error.new(404, 40407), 'Reward found but not active' unless reward[:active]

      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40403), 'Store not found' if store.nil?
      raise Error.new(404, 40405), 'Store found but not active' unless store[:active]

      company = store.relations[:company].first
      raise Error.new(404, 40406), 'Company not found' if company.nil?

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

      raise Error.new(404, 40408), 'Reward does not match company' unless found

      # }}}
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
        # not enough points to redeem
        raise Error.new(422, 42202), "Not enough points to redeem reward" unless reward[:cost] < points[:current]
        # {{{ redeem reward
        begin
          rw_data = {
            title: reward[:title],
            cost: reward[:cost],
            member_key: member.key,
            store_key: store.key,
            redeemed_at: Orchestrate::API::Helpers.timestamp(Time.now)
          }
          redeem = @O_APP[:redeems].create(rw_data)
          begin
            points.decrement('current', reward[:cost]).update()
            # {{{ member stat generation
            sqs = AWS::SQS.new
            queue = sqs.queues.named('storm-generate-member-stats')
            queue.send_message(
              'Points modified',
              message_attributes: {
                "member_key" => {
                  "string_value" => member.key,
                  "data_type" => "String",
                },
                "store_key" => {
                  "string_value" => store.key,
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
              to_key: redeem.key
            },{
              from_collection: 'members',
              from_key: member.key,
              from_name: 'redeems',
              to_collection: 'redeems',
              to_key: redeem.key
            }]
            # queue = sqs.queues.named('storm-generate-relations')
            # queue.send_message(
            #   relations.to_json,
            # )
            Resque.enqueue(Relation, relations)

            # }}}
            # {{{ redemption email
            begin
              clients = []
              query = "store_keys:#{store.key} AND permissions:\"Redemption Notification\""
              response = @O_CLIENT.search(:clients, query)
              loop do
                response.results.each do |client|
                  @O_CLIENT.patch_merge(:clients, client['path']['key'], { permissions: plan[:permissions] })
                  clients << Orchestrate::KeyValue.from_listing(@O_APP[:clients], client, response)
                end

                response = response.next_results
                break if response.nil?
              end
              
              unless clients.empty?
                response = @O_CLIENT.search(:checkins, query, options)
                visits = response.total_count || response.count
                if visits > 0
                  # {{{ merge vars
                  merge_vars = []
                  visits_content = ""
                  case visits
                  when 0...20
                    visits_content = "After #{visits} visits to your business, this customer has redeemed a reward"
                  when 20...50
                    visits_content = "This customer has yella'd here #{visits} times. That's #{visits} whole visits to your business"
                  when 50...100
                    visits_content = "Congratulations - this customer has yella'd here #{visits} times. Wow."
                  else
                    visits_content = "Loyal? More like obsessed! This customer has yella'd here #{visits} times."
                  end
                  address = store['address']
                  merge_vars << {
                    name: "store_name",
                    content: store['name']
                  }
                  merge_vars << {
                    name: "store_addr",
                    content: "#{address['line1']} - #{address['city']}, #{address['state']}"
                  }
                  query = "store_key:#{store.key} AND member_key:#{member.key}"
                  options = {
                    limit: 1
                  }
                  merge_vars << {
                    name: "store_visits",
                    content: visits_content
                  }
                  merge_vars << {
                    name: "reward_name",
                    content: reward['title'],
                  }
                  merge_vars << {
                    name: "reward_cost",
                    content: reward['cost'],
                  }

                  client_emails = []
                  client_merge_vars = []
                  clients.each do |client|
                    redeem_time = Time.at(redeem['redeemed_at'])
                    redeem_time = redeem_time.in_time_zone(client['time_zone']) unless client['time_zone'].nil?
                    vars = [{
                      name: "reward_time",
                      content: redeem_time.strftime('%l:%M %p'),
                    },{
                      name: "reward_date",
                      content: redeem_time.strftime('%m/%d/%y'),
                    }]
                    client_emails << { email: client['email'] }
                    client_merge_vars << { rcpt: client['email'], vars: merge_vars + vars }
                  end

                  # }}}
                  # send email
                  template_name = "new-redeem"
                  template_content = []
                  message = {
                    to: client_emails,
                    headers: {
                      "Reply-To" => 'merchantsupport@getyella.com'
                    },
                    important: true,
                    track_opens: true,
                    track_clicks: true,
                    url_strip_qs: true,
                    merge_vars: client_merge_vars,
                    tags: ['reward-redemption'],
                    google_analytics_domains: ['getyella.com'],
                  }
                  async = false
                  result = @MANDRILL.messages.send_template(template_name, template_content, message, async)
                end
              end
            rescue Orchestrate::API::BaseError => e
              raise Error.new(422, 42205), e.message
            rescue Mandrill::Error => e
              raise Error.new(422, 42206), e.message
            end
             
            # }}}
          rescue Orchestrate::API::BaseError => e
            # unable to subtract points
            @O_CLIENT.delete(:redeems, redeem.key, response.ref)
            raise Error.new(422, 42204), "Reward not redeemed"
          end
        rescue Orchestrate::API::BaseError => e
          # unable to redeem reward
          raise Error.new(422, 42201), e.message
        end

        # }}}
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42203), e.message
      end

      status 201
      data = { success: true }
      body data.to_json
    end

    # }}}
    # stores
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
          points: "/#{self.class.name.demodulize.downcase}/points?store_key=#{s[:key]}&member_key=",
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
    # surveys
    # {{{ get '/surveys', provides: :json do
    get '/surveys', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if params[:member_key].blank?

      # validate params
      member = @O_APP[:members][params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      params[:offset] = 0 if params[:offset].blank? || !params[:offset].numeric?
      params[:limit] = 20 if params[:limit].blank? || !params[:limit].numeric?
      begin
        now = Time.now
        max = Orchestrate::API::Helpers.timestamp(now)
        min = Orchestrate::API::Helpers.timestamp(now - SURVEY_EXP_DAYS.days)
        query = "NOT completed:true AND created_at:[#{min} TO #{max}] AND member_key:#{member.key}"
        options = {
          limit: params[:limit],
          offset: params[:offset],
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
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if params[:member_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: major' if params[:major].blank? || !params[:major].numeric?
      raise Error.new(400, 40003), 'Missing required parameter: minor' if params[:minor].blank? || !params[:minor].numeric?

      # validate params
      member = @O_APP[:members][params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      begin
        query = "major:#{params[:major]} AND minor:#{params[:minor]}"
        options = {
          limit: 1,
        }
        response = @O_CLIENT.search(:codes, query, options)
        raise Error.new(404, 40403), "Beacon not found" if response.count == 0
        unless response.total_count.nil?
          # TODO
          # There's more than one code with that major/minor. Broken.
        end

        code = Orchestrate::KeyValue.from_listing(@O_APP[:codes], response.results.first, response)
        store = code.relations[:store].first
        type = store.relations[:type].first
        raise Error.new(404, 40404), "Store type not found" if type.nil?

        data = {
          answers: type[:questions],
          worth: SURVEY_WORTH,
          member_key: member.key,
          store_key: store.key,
          created_at: Orchestrate::API::Helpers.timestamp(Time.now),
        }
        member_survey = @O_APP[:member_surveys].create(data)
        data[:key] = member_survey.key
        data['_links'] = {
          store: "/#{self.class.name.demodulize.downcase}/stores/#{data[:store_key]}",
        }
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
      
      status 201
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
      # {{{ updates answers
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

      # }}}
      # {{{ update comments
      unless params[:comments].blank?
        begin
          survey[:comments] = params[:comments]
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42203), "Unable to save comments properly"
        end
      end

      # }}}
      # {{{ update nps_score
      if !params[:nps_score].blank? && params[:nps_score].numeric?
        begin
          survey[:nps_score] = params[:nps_score].to_i
          survey.save!
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save nps_score properly"
        end
      end

      # }}}
      # {{{ update completed
      if !params[:completed].blank? && (params[:completed] == 'true' || params[:completed] == true || (params[:completed].numeric? && params[:completed].to_i == 1))
        member = @O_APP[:members][survey[:member_key]]
        raise Error.new(422, 42205), "Unable to find member associated with this survey" if member.nil?

        store = @O_APP[:stores][survey[:store_key]]
        raise Error.new(422, 42206), "Unable to find store associated with this survey" if store.nil?

        company = store.relations[:company].first
        raise Error.new(422, 42207), "Unable to find company associated with this survey" if company.nil?

        begin
          survey[:completed] = true
          survey[:completed_at] = Orchestrate::API::Helpers.timestamp(Time.now)
          survey.save!
          points_keys = Helpers.modify_points(member, company, survey[:worth])
          # {{{ generate member stats
          sqs = AWS::SQS.new
          queue = sqs.queues.named('storm-generate-member-stats')
          queue.send_message(
            'Points modified',
            message_attributes: {
              "member_key" => {
                "string_value" => member.key,
                "data_type" => "String",
              },
              "store_key" => {
                "string_value" => store.key,
                "data_type" => "String",
              }
            }
          )

          # }}}
          # {{{ generate events
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

          # }}}
          # {{{ merchant survey queue
          queue = sqs.queues.named('storm-merchant-survey-queue')
          queue.send_message(
            'Survey completed',
            message_attributes: {
              "member_survey_key" => {
                "string_value" => survey.key,
                "data_type" => "String",
              },
            }
          )

          # }}}
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42201), "Unable to save completed properly"
        end
      end

      # }}}
      status 204
    end

    # }}}
    # checkins
    # {{{ post '/checkins', provides: :json do
    post '/checkins', provides: :json do
      # check for required parameters
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if params[:member_key].blank?
      raise Error.new(400, 40002), 'Missing required parameter: major' if params[:major].blank? || !params[:major].numeric?
      raise Error.new(400, 40003), 'Missing required parameter: minor' if params[:minor].blank? || !params[:minor].numeric?

      # validate params
      member = @O_APP[:members][params[:member_key]]
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
        # {{{ update battery levels
        unless params[:battery].blank?
          batt_lvl = @O_APP[:battery_levels].create({
            level: params[:battery].to_i,
            store_key: store.key,
            read_at: Orchestrate::API::Helpers.timestamp(Time.now),
          })
          store.relations[:battery_levels] << batt_lvl
        end

        # }}}
        data = {
          worth: CHECKIN_WORTH,
          member_key: member.key,
          store_key: store.key,
          created_at: Orchestrate::API::Helpers.timestamp(Time.now),
        }
        checkin = @O_APP[:checkins].create(data)
        data[:key] = checkin.key
        data['_links'] = {
          store: "/#{self.class.name.demodulize.downcase}/stores/#{data[:store_key]}",
        }
        # {{{ relations
        relations = [{
          from_collection: 'codes',
          from_key: code.key,
          from_name: 'checkins',
          to_collection: 'checkins',
          to_key: data[:key]
        },{
          from_collection: 'members',
          from_key: member.key,
          from_name: 'checkins',
          to_collection: 'checkins',
          to_key: data[:key]
        },{
          from_collection: 'stores',
          from_key: store.key,
          from_name: 'checkins',
          to_collection: 'checkins',
          to_key: data[:key]
        },{
          from_collection: 'checkins',
          from_key: data[:key],
          from_name: 'member',
          to_collection: 'members',
          to_key: member.key
        },{
          from_collection: 'checkins',
          from_key: data[:key],
          from_name: 'store',
          to_collection: 'stores',
          to_key: store.key
        },{
          from_collection: 'checkins',
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
        # {{{ member visits
        queue = sqs.queues.named('storm-member-visit')
        queue.send_message(
          'Store Visited',
          message_attributes: {
            "member_key" => {
              "string_value" => member.key,
              "data_type" => "String",
            },
            "store_key" => {
              "string_value" => store.key,
              "data_type" => "String",
            }
          }
        )

        # }}}
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end
      
      status 200
      body data.to_json
    end

    # }}}
  end
end
