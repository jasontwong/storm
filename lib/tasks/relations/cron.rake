namespace :relations do
  namespace :cron do
    # {{{ vars
    oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end

    # }}}
    # {{{ desc "Events: Generate relations via SQS"
    desc "Events: Generate relations via SQS"
    task :sqs_relations do
      sqs = AWS::SQS.new
      queue = sqs.queues.named('storm-generate-relations')
      queue.poll(idle_timeout: 5) do |msg|
        # [{
        #   from_collection: 'members',
        #   from_key: member.key,
        #   from_name: 'surveys',
        #   to_collection: 'member_surveys',
        #   to_key: data[:key]
        # }]
        relations = JSON.parse(msg.body, symbolize_names: true)
        relations.each do |data|
          oclient.put_relation(data[:from_collection], data[:from_key], data[:from_name], data[:to_collection], data[:to_key])
        end
      end
    end

    # }}}
  end
end
