require 'resque/errors'
require_relative 'retried_job'

class Email
  extend RetriedJob

  @queue = :email
  # {{{ def initialize(email)
  def initialize(email)
    @O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :typhoeus
    end

    @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :typhoeus
    end

    @MANDRILL = Mandrill::API.new ENV['MANDRILL_API_KEY']
    @email = email
  end

  # }}}
  # {{{ def self.perform(email)
  def self.perform(email)
    (new email).send_email
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  # }}}
  # {{{ def send_email
  def send_email
    template_name = @email['type']
    case @email['type']
    # {{{ when 'forgot-pw'
    when 'forgot-pw'
      template_content = []
      message = {
        to: [{
          email: @email['to_email'],
          type: 'to'
        }],
        from_email: @email['from_email'],
        headers: {
          "Reply-To" => @email['from_email'],
        },
        important: true,
        track_opens: true,
        track_clicks: true,
        url_strip_qs: true,
        merge_vars: [{
          rcpt: @email['to_email'],
          vars: [{
            name: "pass_reset_url",
            content: "http://www.getyella.com/pass_reset?email=#{@email['to_email']}&temp_pass=#{@email['temp_pass']}",
          }]
        }],
        tags: ['password-reset'],
        google_analytics_domains: ['getyella.com'],
      }
      async = false
      result = @MANDRILL.messages.send_template(template_name, template_content, message, async)

    # }}}
    # {{{ when 'new-redeem'
    when 'new-redeem'
      clients = []
      query = "store_keys:#{@email['store_key']} AND permissions:\"Redemption Notification\""
      options = {
        limit: 100
      }
      response = @O_CLIENT.search(:clients, query, options)
      loop do
        clients += response.results
        response = response.next_results
        break if response.nil?
      end

      unless clients.empty?
        query = "company_key:#{@email['company_key']} AND member_key:#{@email['member_key']}"
        options[:limit] = 1
        response = @O_CLIENT.search(:checkins, query, options)
        visits = response.total_count || response.count
        if visits > 0
          # {{{ merge vars
          merge_vars = []
          store = @O_APP[:stores][@email['store_key']]
          address = store['address']
          merge_vars << {
            name: "store_name",
            content: store['name']
          }
          merge_vars << {
            name: "store_addr",
            content: store['full_address']
          }
          merge_vars << {
            name: "store_visits",
            content: visits
          }
          reward = @O_APP[:rewards][@email['reward_key']]
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
            redeem_time = Time.at(@email['redeemed_at'].to_f / 1000)
            redeem_time = redeem_time.in_time_zone(client['value']['time_zone']) unless client['value']['time_zone'].nil?
            vars = [{
              name: "reward_time",
              content: redeem_time.strftime('%l:%M %p'),
            },{
              name: "reward_date",
              content: redeem_time.strftime('%m/%d/%y'),
            }]
            client_emails << { email: client['value']['email'] }
            client_merge_vars << { rcpt: client['value']['email'], vars: merge_vars + vars }
          end

          # }}}
          # send email
          template_name = "new-redeem"
          template_content = []
          message = {
            to: client_emails,
            from_email: @email['from_email'],
            headers: {
              "Reply-To" => @email['from_email']
            },
            preserve_recipients: false,
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

    # }}}
    # {{{ when 'checkin'
    when 'checkin'
      member = @O_APP[:members][@email['member_key']]
      if member[:notifications] && member[:notifications].include?('checkin')
        store = @O_APP[:stores][@email['store_key']]
        company = @O_APP[:companies][@email['company_key']]
        worth = @email['worth']
        merge_vars = [{
          name: "store_name",
          content: store[:display_name]
        },{
          name: "company_logo",
          content: company[:logo]
        },{
          name: "tweet_text",
          content: "I got #{worth} points for checking into (#{store[:display_name]}) by using @getyella"
        },{
          name: "num_points",
          content: worth,
        },{
          name: "member_key",
          content: @email['member_key']
        }]
        template_name = "checkin"
        template_content = []
        message = {
          to: [{
            email: @email['member_email']
          }],
          subject: [
            'Yippee! Points',
            'Points on top of Points',
            'Points goin’ up',
            'You checked in!',
            'You’ve got points',
            'Points Galore',
            'Rackin Up Points',
          ].sample,
          preserve_recipients: false,
          important: true,
          track_opens: true,
          track_clicks: true,
          url_strip_qs: true,
          global_merge_vars: merge_vars,
          tags: ['checkin-email'],
          google_analytics_domains: ['getyella.com'],
        }
        async = false
        result = @MANDRILL.messages.send_template(template_name, template_content, message, async)
      end

    # }}}
    # {{{ when 'reward-redeem'
    when 'reward-redeem'
      member = @O_APP[:members][@email['member_key']]
      if member[:notifications] && member[:notifications].include?('redeem')
        redeem = @O_APP[:redeems][@email['redeem_key']]
        store = @O_APP[:stores][redeem[:store_key]]
        response = @O_CLIENT.search(:points, "member_key:#{redeem[:member_key]} AND company_key:#{redeem[:company_key]}")
        points = response.results.first
        response = @O_CLIENT.search(:checkins, "member_key:#{redeem[:member_key]} AND company_key:#{redeem[:company_key]}", { limit: 1 })
        num_visits = response.total_count
        company = @O_APP[:companies][redeem[:company_key]]
        response = @O_CLIENT.search(:rewards, "company_key:#{company.key}", { limit: 100, sort: "cost:asc" })
        merge_vars = [{
          name: "company_name",
          content: company[:name]
        },{
          name: "company_logo",
          content: company[:logo]
        },{
          name: "reward_cost",
          content: redeem[:cost]
        },{
          name: "reward_name",
          content: redeem[:title]
        },{
          name: "member_points",
          content: "#{points['value']['current']}"
        },{
          name: "member_visits",
          content: num_visits
        },{
          name: "tweet_text",
          content: URI.encode("I just got a free reward at #{store[:display_name]} using @getyella")
        }]
        template_name = "reward-redeem"
        template_content = []
        message = {
          to: [{
            email: member[:email]
          }],
          preserve_recipients: false,
          important: true,
          track_opens: true,
          track_clicks: true,
          url_strip_qs: true,
          global_merge_vars: merge_vars,
          tags: ['reward-redeem'],
          google_analytics_domains: ['getyella.com'],
        }
        async = false
        result = @MANDRILL.messages.send_template(template_name, template_content, message, async)
      end

    # }}}
    end

    flush "Sending #{@email["type"]}"
  end

  # }}}
  # {{{ def flush(str)
  def flush(str)
    puts str
    $stdout.flush
  end
  
  # }}}
end
