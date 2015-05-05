require 'orchestrate'
require 'multi_json'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'securerandom'

# {{{ class Point
class Point
  attr_reader :pkey, :points
  # {{{ def initialize(mkey, ckey)
  def initialize(mkey, ckey)
    @pkey = nil
    @points = nil
    @mkey = mkey
    @ckey = ckey
    @o_app = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :typhoeus
    end
    @o_client = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :typhoeus
    end
    query = "company_key:#{ckey} AND member_key:#{mkey}"
    options = {
      limit: 1
    }
    response = @o_client.search(:points, query, options)
    unless response.total_count.nil?
      # TODO
      # There is a bug that allowed two sets of points notify admin
    end
    unless response.results.empty?
      @points = response.results.first
      @pkey = @points['path']['key']
    end
  end

  # }}}
  # {{{ def modify_points(num)
  def modify_points(num)
    pkey = get_pkey
    num = num.to_i
    ops = []
    if num > 0
      ops << {
        op: 'add',
        path: 'last_earned',
        value: Orchestrate::API::Helpers.timestamp(Time.now)
      }
      ops << {
        op: 'inc',
        path: 'total',
        value: num
      }
    end
    ops << {
      op: 'inc',
      path: 'current',
      value: num
    }
    @o_client.patch(:points, pkey, ops)
  end

  # }}}
  private
  # {{{ def get_pkey
  def get_pkey
    return @pkey unless @pkey.nil?
    point_data = {
      current: 0,
      total: 0,
      member_key: @mkey,
      company_key: @ckey
    }
    points = @o_app[:points].create(point_data)
    @pkey = points.key
    @points = {
      'path': {
        'key': @pkey
      },
      'value': points.value
    }
    relations = [{
      from_collection: 'members',
      from_key: @mkey,
      from_name: 'points',
      to_collection: 'points',
      to_key: @pkey
    },{
      from_collection: 'companies',
      from_key: @ckey,
      from_name: 'points',
      to_collection: 'points',
      to_key: @pkey
    }]
    Resque.enqueue(Relation, relations)
    @pkey
  end

  # }}}
end

# }}}
module Storm
  class V0 < Base
    # {{{ before do
    before do
      halt 404 if settings.production? && !request.secure?
      halt 426 if !request.env['HTTP_X_IOS_SDK_VERSION'].nil? && request.env['HTTP_X_IOS_SDK_VERSION'].to_f < 2.0
      halt 426 if !request.env['HTTP_X_ANDROID_SDK_VERSION'].nil? && request.env['HTTP_X_ANDROID_SDK_VERSION'].to_f < 2.0
      @O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :typhoeus
      end

      @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :typhoeus
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

      if request.post? || request.patch? || request.put?
        @post_params = request.POST.symbolize_keys
      end
    end

    # }}}
    # members
    # {{{ post '/members/login', provides: :json do
    post '/members/login', provides: :json do
      if !@post_params[:fb_id].blank?
        # FB login
        ::NewRelic::Agent.add_custom_parameters({ fb_id: @post_params[:fb_id] })
        raise Error.new(400, 40002), 'Facebook ID is not a number' unless @post_params[:fb_id].numeric?

        response = @O_CLIENT.search(:members, "fb_id:#{@post_params[:fb_id]}")
        raise Error.new(404, 40400), 'Facebook ID not found' if response.results.empty?

        member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
      elsif !@post_params[:member_id].blank?
        # Login from old version of app
        ::NewRelic::Agent.add_custom_parameters({ member_id: @post_params[:member_id] })
        raise Error.new(400, 40003), 'Member ID is not a number' unless @post_params[:member_id].numeric?

        response = @O_CLIENT.search(:members, "old_id:#{@post_params[:member_id]}")
        raise Error.new(404, 40401), 'Member not found' if response.results.empty?

        member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
      elsif !@post_params[:email].blank? && !@post_params[:password].blank?
        # Email/Pass login
        ::NewRelic::Agent.add_custom_parameters({ email: @post_params[:email] })
        response = @O_CLIENT.search(:members, "email:#{@post_params[:email]}")
        raise Error.new(404, 40401), 'Member not found' if response.results.empty?

        member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
        password = Digest::SHA256.new
        password.update @post_params[:password] + member[:salt]
        old_pass = Digest::SHA256.new
        old_pass.update @post_params[:password]
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
      
      ::NewRelic::Agent.add_custom_parameters({ member_key: member.key })
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
      ::NewRelic::Agent.add_custom_parameters({ email: @post_params[:email] })
      raise Error.new(400, 40001), 'Missing required parameter: email' if @post_params[:email].blank?

      member_data = {
        email: @post_params[:email].downcase.strip,
        salt: SecureRandom.hex,
        active: true,
        stats: { 
          points: {},
          rewards: {},
          stores: {},
          surveys: {}
        },
        notifications: [
          'redeem',
          'checkin'
        ]
      }
      raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(member_data[:email])

      response = @O_CLIENT.search(:members, "email:#{member_data[:email]}")
      raise Error.new(422, 42202), 'Email already exists' unless response.results.empty?

      # check for type of login
      unless @post_params[:fb_id].blank?
        ::NewRelic::Agent.add_custom_parameters({ fb_id: @post_params[:fb_id] })
        raise Error.new(400, 40002), 'Facebook ID is not a number' unless @post_params[:fb_id].numeric?

        response = @O_CLIENT.search(:members, "fb_id:#{@post_params[:fb_id]}")
        raise Error.new(422, 42205), 'Facebook ID already in use' unless response.results.empty?

        @post_params[:password] = SecureRandom.hex
        member_data[:fb_id] = @post_params[:fb_id].to_i
      else
        # check for password strength
        raise Error.new(422, 42204), 'Password is not valid' unless !@post_params[:password].blank? && @post_params[:password].length >= 6
      end

      # validate attributes key
      unless @post_params[:attributes].blank?
        ::NewRelic::Agent.add_custom_parameters({ attributes: @post_params[:attributes] })
        unless @post_params[:attributes].is_a? Hash
          begin
            @post_params[:attributes] = JSON.parse(@post_params[:attributes], symbolize_names: true)
          rescue JSON::ParserError => e
            @post_params[:attributes] = {}
          end
        end
      else
        @post_params[:attributes] = {}
      end

      begin
        member_data[:attributes] = @post_params[:attributes]
        password = Digest::SHA256.new
        password.update @post_params[:password] + member_data[:salt]
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
      ::NewRelic::Agent.add_custom_parameters({ email: @post_params[:email] })
      raise Error.new(400, 40001), 'Missing required parameter: email' if @post_params[:email].blank?

      email = @post_params[:email].downcase.strip
      raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(email)

      response = @O_CLIENT.search(:members, "email:#{email}")
      raise Error.new(404, 40401), 'Member not found' if response.results.empty?

      member = Orchestrate::KeyValue.from_listing(@O_APP[:members], response.results.first, response)
      ::NewRelic::Agent.add_custom_parameters({ member_key: member.key })
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      begin
        member[:temp_pass] = SecureRandom.hex
        member[:temp_expiry] = Orchestrate::API::Helpers.timestamp(Time.now + 1.day)
        member.save!
        # send out email
        Resque.enqueue(Email, {
          type: 'forgot-pw',
          to_email: member[:email],
          from_email: "support@getyella.com",
          temp_pass: member[:temp_pass]
        })
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42202), e.message
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
      member = @O_APP[:members][params[:key]]
      ::NewRelic::Agent.add_custom_parameters({ key: params[:key] })
      raise Error.new(404, 40401), "Member not found" if member.nil?
      ::NewRelic::Agent.add_custom_parameters({ member_key: member.key })
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
      ::NewRelic::Agent.add_custom_parameters({ key: params[:key] })
      raise Error.new(404, 40401), "Member not found" if member.nil?
      ::NewRelic::Agent.add_custom_parameters({ member_key: member.key })
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]
      # {{{ update email
      unless @post_params[:email].blank?
        email = @post_params[:email].downcase.strip
        ::NewRelic::Agent.add_custom_parameters({ email: @post_params[:email] })
        raise Error.new(422, 42201), 'Email is not valid' unless VALID_EMAIL_REGEX.match(email)

        response = @O_CLIENT.search(:members, "email:#{email} AND NOT key:#{member.key}")
        raise Error.new(422, 42206), 'Email already in use' unless response.results.empty?

        begin
          member.replace('email', email).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42202), msg
        end
      end

      # }}}
      # {{{ update attributes
      unless @post_params[:attributes].blank?
        begin
          attributes = nil
          attributes = @post_params[:attributes] if @post_params[:attributes].is_a? Hash
          attributes = JSON.parse(@post_params[:attributes]) if attributes.nil?
          member.replace('attributes', member[:attributes].merge(attributes)).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          ::NewRelic::Agent.add_custom_parameters({ attributes: @post_params[:attributes] })
          raise Error.new(422, 42203), "Unable to save attributes properly"
        rescue JSON::ParserError => e
          ::NewRelic::Agent.add_custom_parameters({ attributes: @post_params[:attributes] })
          raise Error.new(400, 40002), "Unable to parse attributes properly"
        end
      end

      # }}}
      # {{{ update fb_id
      unless @post_params[:fb_id].blank?
        ::NewRelic::Agent.add_custom_parameters({ fb_id: @post_params[:fb_id] })
        raise Error.new(400, 40001), 'Facebook ID is not a number' unless @post_params[:fb_id].numeric?

        response = @O_CLIENT.search(:members, "fb_id:#{@post_params[:fb_id]} AND NOT key:#{member.key}")
        raise Error.new(422, 42205), 'Facebook ID already in use' unless response.results.empty?

        begin
          member.replace('fb_id', @post_params[:fb_id].to_i).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          raise Error.new(422, 42204), "Unable to save Facebook ID properly"
        end
      end

      # }}}
      # {{{ update password
      unless @post_params[:password].blank?
        raise Error.new(422, 42205), 'Password is not valid' unless @post_params[:password].length >= 6

        begin
          password = Digest::SHA256.new
          password.update @post_params[:password] + member[:salt]
          member.replace('password', password.hexdigest).update
          member.reload
        rescue Orchestrate::API::BaseError => e
          ::NewRelic::Agent.add_custom_parameters({ password: @post_params[:password] })
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
      ::NewRelic::Agent.add_custom_parameters({ key: params[:key] })
      raise Error.new(404, 40401), "Member not found" if member.nil?
      ::NewRelic::Agent.add_custom_parameters({ member_key: member.key })
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
      ::NewRelic::Agent.add_custom_parameters({ store_key: params[:store_key] })
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ member_key: params[:member_key] })
      raise Error.new(400, 40002), 'Missing required parameter: member_key' if params[:member_key].blank?

      # validate params
      member = @O_APP[:members][params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40403), 'Member found but not active' unless member[:active]

      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40402), 'Store not found' if store.nil?
      raise Error.new(404, 40404), 'Store found but not active' unless store[:active]

      begin
        ::NewRelic::Agent.add_custom_parameters({ company_key: store[:company_key] })
        point = Point.new(member.key, store[:company_key])
        # TODO Remove 404 and return 0 points instead
        # we couldn't find points that are associated with this key/member combination
        raise Error.new(404, 40406), "Member does not have any points at this company" if point.pkey.nil?
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end

      data = point.points['value']
      data.delete_if { |k, v| ['member_key', 'company_key'].include? k }
      status 200
      body data.to_json
    end

    # }}}
    # {{{ patch '/points', provides: :json do
    patch '/points', provides: :json do
      # check for required parameters
      ::NewRelic::Agent.add_custom_parameters({ store_key: @post_params[:store_key] })
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if @post_params[:store_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ member_key: @post_params[:member_key] })
      raise Error.new(400, 40002), 'Missing required parameter: member_key' if @post_params[:member_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ points: @post_params[:points] })
      raise Error.new(400, 40003), 'Missing required parameter: points' if @post_params[:points].blank? || !@post_params[:points].numeric?

      # validate params
      member = @O_APP[:members][@post_params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40403), 'Member found but not active' unless member[:active]

      store = @O_APP[:stores][@post_params[:store_key]]
      raise Error.new(404, 40402), 'Store not found' if store.nil?
      raise Error.new(404, 40404), 'Store found but not active' unless store[:active]

      begin
        ::NewRelic::Agent.add_custom_parameters({ company_key: store[:company_key] })
        point = Point.new(member.key, store[:company_key])
        point.modify_points(@post_params[:points].to_i)
        # {{{ stats
        stats = {
          type: 'points',
          mkey: member.key,
          skey: store.key
        }
        Resque.enqueue(Stat, stats)

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
      ::NewRelic::Agent.add_custom_parameters({ store_key: params[:store_key] })
      raise Error.new(400, 40001), 'Missing required parameter: store_key' if params[:store_key].blank?

      # validate params
      store = @O_APP[:stores][params[:store_key]]
      raise Error.new(404, 40401), 'Store not found' if store.nil?
      raise Error.new(404, 40402), 'Store found but not active' unless store[:active]

      ::NewRelic::Agent.add_custom_parameters({ company_key: store[:company_key] })
      query = "company_key:#{store[:company_key]} AND active:true"
      unless params[:member_key].blank?
        ::NewRelic::Agent.add_custom_parameters({ member_key: params[:member_key] })
        member = @O_APP[:members][params[:member_key]]
        raise Error.new(404, 40401), 'Member not found' if member.nil?
        raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

        point = Point.new(member.key, store[:company_key])
        # we couldn't find points that are associated with this key/member combination
        query += point.pkey.nil? ? " AND cost:[-100 TO -50]" : " AND cost:[0 TO #{point.points['value']['current']}]"
      end

      begin
        data = []
        response = @O_CLIENT.search(:rewards, query)
        loop do
          response.results.each do |reward|
            r = reward['value']
            r[:key] = reward['path']['key']
            r.delete_if { |k, v| ['active', 'company_key'].include? k }
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
      ::NewRelic::Agent.add_custom_parameters({ member_key: @post_params[:member_key] })
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if @post_params[:member_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ reward_key: @post_params[:reward_key] })
      raise Error.new(400, 40002), 'Missing required parameter: reward_key' if @post_params[:reward_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ store_key: @post_params[:store_key] })
      raise Error.new(400, 40003), 'Missing required parameter: store_key' if @post_params[:store_key].blank?

      member = @O_APP[:members][@post_params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40404), 'Member found but not active' unless member[:active]

      reward = @O_APP[:rewards][@post_params[:reward_key]]
      raise Error.new(404, 40402), 'Reward not found' if reward.nil?
      raise Error.new(404, 40407), 'Reward found but not active' unless reward[:active]

      store = @O_APP[:stores][@post_params[:store_key]]
      raise Error.new(404, 40403), 'Store not found' if store.nil?
      raise Error.new(404, 40405), 'Store found but not active' unless store[:active]
      raise Error.new(404, 40408), 'Reward does not match company' unless reward[:company_key] == store[:company_key]

      # }}}
      begin
        ::NewRelic::Agent.add_custom_parameters({ company_key: store[:company_key] })
        point = Point.new(member.key, store[:company_key])
        # we couldn't find points that are associated with this key/member combination
        raise Error.new(422, 42202), "Not enough points to redeem reward" if point.pkey.nil? || reward[:cost] > point.points['value']['current']
        # {{{ redeem reward
        begin
          rw_data = {
            title: reward[:title],
            cost: reward[:cost],
            member_key: member.key,
            store_key: store.key,
            company_key: store[:company_key],
            redeemed_at: Orchestrate::API::Helpers.timestamp(Time.now)
          }
          redeem = @O_APP[:redeems].create(rw_data)
          begin
            point.modify_points(reward[:cost] * -1)
            # {{{ stats
            stats = {
              type: 'redeem',
              mkey: member.key,
              skey: store.key
            }
            Resque.enqueue(Stat, stats)

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
            Resque.enqueue(Relation, relations)

            # }}}
            # {{{ redemption email
            redemption = {
              type: 'new-redeem',
              company_key: store[:company_key],
              store_key: store.key,
              member_key: member.key,
              reward_key: reward.key,
              redeemed_at: rw_data[:redeemed_at],
              from_email: "merchantsupport@getyella.com",
            }
            Resque.enqueue(Email, redemption)

            # }}}
            # {{{ reward redeem email
            redemption = {
              type: 'reward-redeem',
              redeem_key: redeem.key,
              member_key: member.key
            }
            Resque.enqueue(Email, redemption)

            # }}}
          rescue Orchestrate::API::BaseError => e
            redeem.destroy!
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
      ::NewRelic::Agent.add_custom_parameters({ latitude: params[:latitude] })
      raise Error.new(400, 40001), 'Missing required parameter: latitude' if params[:latitude].blank? || !params[:latitude].numeric?
      ::NewRelic::Agent.add_custom_parameters({ longitude: params[:longitude] })
      raise Error.new(400, 40002), 'Missing required parameter: longitude' if params[:longitude].blank? || !params[:longitude].numeric?
      
      params[:distance] = '1mi' if params[:distance].blank?
      params[:offset] = 0 if params[:offset].blank? || !params[:offset].numeric?
      params[:limit] = 20 if params[:limit].blank? || !params[:limit].numeric?
      query = "location:NEAR:{lat:#{params[:latitude]} lon:#{params[:longitude]} dist:#{params[:distance]}}"
      options = {
        sort: 'location:distance:asc',
        offset: params[:offset],
        limit: params[:limit]
      }
      ::NewRelic::Agent.add_custom_parameters({ query: query, options: options })
      # TODO Catch orchestrate errors
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
      ::NewRelic::Agent.add_custom_parameters({ key: params[:key] })
      raise Error.new(404, 40401), "Store not found" if store.nil?
      ::NewRelic::Agent.add_custom_parameters({ store_key: store.key })
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
      ::NewRelic::Agent.add_custom_parameters({ member_key: params[:member_key] })
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
        ::NewRelic::Agent.add_custom_parameters({ query: query, options: options })
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
      ::NewRelic::Agent.add_custom_parameters({ member_key: @post_params[:member_key] })
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if @post_params[:member_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ major: @post_params[:major] })
      raise Error.new(400, 40002), 'Missing required parameter: major' if @post_params[:major].blank? || !@post_params[:major].numeric?
      ::NewRelic::Agent.add_custom_parameters({ minor: @post_params[:minor] })
      raise Error.new(400, 40003), 'Missing required parameter: minor' if @post_params[:minor].blank? || !@post_params[:minor].numeric?

      # validate params
      member = @O_APP[:members][@post_params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      begin
        query = "major:#{@post_params[:major]} AND minor:#{@post_params[:minor]}"
        options = {
          limit: 1,
        }
        ::NewRelic::Agent.add_custom_parameters({ query: query, options: options })
        response = @O_CLIENT.search(:codes, query, options)
        raise Error.new(404, 40403), "Beacon not found" if response.count == 0

        unless response.total_count.nil?
          # TODO
          # There's more than one code with that major/minor. Broken.
        end

        code = Orchestrate::KeyValue.from_listing(@O_APP[:codes], response.results.first, response)
        store = code.relations[:store].first
        survey = store.relations[:survey].first
        data = {
          answers: survey.nil? ? [] : survey[:questions],
          worth: survey.nil? ? 0 : SURVEY_WORTH,
          member_key: member.key,
          store_key: store.key,
          company_key: store[:company_key],
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
        Resque.enqueue(Relation, relations)

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
      ::NewRelic::Agent.add_custom_parameters({ key: params[:key] })
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
      ::NewRelic::Agent.add_custom_parameters({ key: params[:key] })
      raise Error.new(404, 40401), "Survey not found" if survey.nil?
      raise Error.new(422, 42205), "Survey is already completed" if !survey[:completed].blank? && survey[:completed] == true

      # TODO
      # Figure out a better way to handle answers, large payload
      # {{{ update answers
      unless @post_params[:answers].blank?
        begin
          answers = nil
          answers = @post_params[:answers] if @post_params[:answers].is_a? Array
          answers = JSON.parse(@post_params[:answers]) if answers.nil?
          survey[:answers] = answers.collect do |answer|
            answer["answer"] = answer["answer"].to_f unless answer["type"] == 'switch'
            answer
          end

          survey.save!
        rescue Orchestrate::API::BaseError => e
          ::NewRelic::Agent.add_custom_parameters({ answers: @post_params[:answers] })
          raise Error.new(422, 42202), "Unable to save answers properly"
        rescue JSON::ParserError => e
          ::NewRelic::Agent.add_custom_parameters({ answers: @post_params[:answers] })
          raise Error.new(400, 40001), "Unable to parse answers properly"
        end
      end

      # }}}
      # {{{ update comments
      unless @post_params[:comments].blank?
        begin
          survey[:comments] = @post_params[:comments]
          survey.save!
        rescue Orchestrate::API::BaseError => e
          ::NewRelic::Agent.add_custom_parameters({ comments: @post_params[:comments] })
          raise Error.new(422, 42203), "Unable to save comments properly"
        end
      end

      # }}}
      # {{{ update first_time
      if !@post_params[:first_time].blank? && (@post_params[:first_time] == 'true' || @post_params[:first_time] == true || (@post_params[:first_time].numeric? && @post_params[:first_time].to_i == 1))
        begin
          survey[:first_time] = true
          survey.save!
        rescue Orchestrate::API::BaseError => e
          ::NewRelic::Agent.add_custom_parameters({ first_time: @post_params[:first_time] })
          raise Error.new(422, 42204), "Unable to save first_time properly"
        end
      end

      # }}}
      # {{{ update visit_rating
      if !@post_params[:visit_rating].blank? && @post_params[:visit_rating].numeric? && [0, 1].include?(@post_params[:visit_rating].to_i)
        begin
          survey[:visit_rating] = @post_params[:visit_rating].to_i
          survey.save!
        rescue Orchestrate::API::BaseError => e
          ::NewRelic::Agent.add_custom_parameters({ visit_rating: @post_params[:visit_rating] })
          raise Error.new(422, 42205), "Unable to save visit_rating properly"
        end
      end

      # }}}
      # {{{ update completed
      if !@post_params[:completed].blank? && (@post_params[:completed] == 'true' || @post_params[:completed] == true || (@post_params[:completed].numeric? && @post_params[:completed].to_i == 1))
        ::NewRelic::Agent.add_custom_parameters({ completed: @post_params[:completed] })
        member = @O_APP[:members][survey[:member_key]]
        ::NewRelic::Agent.add_custom_parameters({ member_key: survey[:member_key] })
        raise Error.new(422, 42205), "Unable to find member associated with this survey" if member.nil?

        store = @O_APP[:stores][survey[:store_key]]
        ::NewRelic::Agent.add_custom_parameters({ store_key: survey[:store_key] })
        raise Error.new(422, 42206), "Unable to find store associated with this survey" if store.nil?

        begin
          survey[:completed] = true
          survey[:completed_at] = Orchestrate::API::Helpers.timestamp(Time.now)
          survey.save!
          @O_APP[:queues].create({
            type: 'feedback',
            survey_key: survey.key,
            created_at: Orchestrate::API::Helpers.timestamp(Time.now)
          })

          point = Point.new(member.key, store[:company_key])
          point.modify_points(survey[:worth])
          # {{{ stats
          stats = {
            type: 'survey',
            mkey: member.key,
            skey: store.key
          }
          Resque.enqueue(Stat, stats)

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
      ::NewRelic::Agent.add_custom_parameters({ member_key: @post_params[:member_key] })
      raise Error.new(400, 40001), 'Missing required parameter: member_key' if @post_params[:member_key].blank?
      ::NewRelic::Agent.add_custom_parameters({ major: @post_params[:major] })
      raise Error.new(400, 40002), 'Missing required parameter: major' if @post_params[:major].blank? || !@post_params[:major].numeric?
      ::NewRelic::Agent.add_custom_parameters({ minor: @post_params[:minor] })
      raise Error.new(400, 40003), 'Missing required parameter: minor' if @post_params[:minor].blank? || !@post_params[:minor].numeric?

      # validate params
      member = @O_APP[:members][@post_params[:member_key]]
      raise Error.new(404, 40401), 'Member not found' if member.nil?
      raise Error.new(404, 40402), 'Member found but not active' unless member[:active]

      begin
        query = "major:#{@post_params[:major]} AND minor:#{@post_params[:minor]}"
        options = {
          limit: 1,
        }
        ::NewRelic::Agent.add_custom_parameters({ query: query, options: options })
        response = @O_CLIENT.search(:codes, query, options)
        raise Error.new(404, 40400), "Beacon not found" if response.count == 0

        unless response.total_count.nil?
          # TODO
          # There's more than one code with that major/minor. Broken.
        end

        code = Orchestrate::KeyValue.from_listing(@O_APP[:codes], response.results.first, response)
        store = code.relations[:store].first
        raise Error.new(404, 40403), "Store not found" if store.nil?
        raise Error.new(404, 40404), "Store found but not active" unless store[:active]
        # {{{ update battery levels
        unless @post_params[:battery].blank?
          ::NewRelic::Agent.add_custom_parameters({ battery_levels: @post_params[:battery_levels] })
          batt_lvl = @O_APP[:battery_levels].create({
            level: @post_params[:battery].to_i,
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
          company_key: store[:company_key],
          created_at: @post_params[:created_at] ? @post_params[:created_at].to_i : Orchestrate::API::Helpers.timestamp(Time.now),
        }
        checkin = @O_APP[:checkins].create(data)
        data[:key] = checkin.key
        data['_links'] = {
          store: "/#{self.class.name.demodulize.downcase}/stores/#{data[:store_key]}",
        }
        begin
          point = Point.new(member.key, store[:company_key])
          point.modify_points(CHECKIN_WORTH)
        rescue Orchestrate::API::BaseError => e
          checkin.destroy!
          raise Error.new(422, 42202), e.message
        end
        {{{ checkin email
        Resque.enqueue(Email, {
          type: 'checkin',
          worth: CHECKIN_WORTH,
          store_key: store.key,
          company_key: store[:company_key],
          member_key: member.key,
          member_email: member[:email],
        })

        # }}}
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
        Resque.enqueue(Relation, relations)

        # }}}
        # {{{ stats
        stats = {
          type: 'checkin',
          mkey: member.key,
          skey: store.key
        }
        Resque.enqueue(Stat, stats)

        # }}}
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end
      
      status 200
      body data.to_json
    end

    # }}}
    # codes
    # {{{ post '/codes/verify', provides: :json do
    post '/codes/verify', provides: :json do
      # check for required parameters
      ::NewRelic::Agent.add_custom_parameters({ major: @post_params[:major] })
      raise Error.new(400, 40002), 'Missing required parameter: major' if @post_params[:major].blank? || !@post_params[:major].numeric?
      ::NewRelic::Agent.add_custom_parameters({ minor: @post_params[:minor] })
      raise Error.new(400, 40003), 'Missing required parameter: minor' if @post_params[:minor].blank? || !@post_params[:minor].numeric?

      begin
        query = "major:#{@post_params[:major]} AND minor:#{@post_params[:minor]}"
        options = {
          limit: 1,
        }
        ::NewRelic::Agent.add_custom_parameters({ query: query, options: options })
        response = @O_CLIENT.search(:codes, query, options)
        raise Error.new(404, 40400), "Beacon not found" if response.count == 0
        unless response.total_count.nil?
          # TODO
          # There's more than one code with that major/minor. Broken.
        end

        code = Orchestrate::KeyValue.from_listing(@O_APP[:codes], response.results.first, response)
        store = code.relations[:store].first
        raise Error.new(404, 40401), "Store not found" if store.nil?
        ::NewRelic::Agent.add_custom_parameters({ store_key: store.key })
        raise Error.new(404, 40402), "Store found but not active" unless store[:active]
        
        data = {
          success: true,
          store_key: store.key
        }
      rescue Orchestrate::API::BaseError => e
        raise Error.new(422, 42201), e.message
      end
      
      status 200
      body data.to_json
    end

    # }}}
  end
end
