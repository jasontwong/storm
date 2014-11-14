namespace :events do
  namespace :cron do
    # {{{ vars
    oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end

    # }}}
    # {{{ desc "Events: Generate events via SQS"
    desc "Events: Generate events via SQS"
    task :sqs_events do
      sqs = AWS::SQS.new
      queue = sqs.queues.named('storm-generate-events')
      attributes = %w[collection event_name]
      keys = []
      queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
        attrs = msg.message_attributes
        data = JSON.parse(msg.body, symbolize_names: true)
        data[:keys].each do |key|
          oclient.post_event(attrs['collection'][:string_value], key, attrs['event_name'][:string_value], data[:data])
        end
      end
    end

    # }}}
  end
end
