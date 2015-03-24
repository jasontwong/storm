require 'resque/errors'
require_relative 'retried_job'

class Email
  extend RetriedJob

  @queue = :email
  # {{{ def initialize(email)
  def initialize(email)
    @O_APP = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end

    @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
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
        query = "store_key:#{@email['store_key']} AND member_key:#{@email['member_key']}"
        options[:limit] = 1
        response = @O_CLIENT.search(:checkins, query, options)
        visits = response.total_count || response.count
        if visits > 0
          # {{{ merge vars
          merge_vars = []
          visits_content = ""
          case visits
          when 1
            visits_content = "After #{visits} visit to your business, this customer has redeemed a reward"
          when 1...20
            visits_content = "After #{visits} visits to your business, this customer has redeemed a reward"
          when 20...50
            visits_content = "This customer has yella'd here #{visits} times. That's #{visits} whole visits to your business"
          when 50...100
            visits_content = "Congratulations - this customer has yella'd here #{visits} times. Wow."
          else
            visits_content = "Loyal? More like obsessed! This customer has yella'd here #{visits} times."
          end
          store = @O_APP[:stores][@email['store_key']]
          address = store['address']
          merge_vars << {
            name: "store_name",
            content: store['name']
          }
          merge_vars << {
            name: "store_addr",
            content: "#{address['line1']} - #{address['city']}, #{address['state']}"
          }
          merge_vars << {
            name: "store_visits",
            content: visits_content
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
