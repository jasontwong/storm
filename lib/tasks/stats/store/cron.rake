namespace :stats do
  namespace :store do
    namespace :cron do
      # {{{ vars
      oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      # }}}
      # {{{ desc "Store: Generate stats for all"
      desc "Store: Generate stats for all"
      task :all_stats do
        stores = oapp[:stores]
        stores.each do |store|
          Rake::Task['stats:store:generate'].reenable
          Rake::Task['stats:store:generate'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:store:generate'].invoke(store.key)
          sleep(3)
        end
      end

      # }}}
      # {{{ desc "Store: Generate stats for stores via SQS"
      desc "Store: Generate stats for stores via SQS"
      task :sqs_stats do
        # TODO
        # sqs = AWS::SQS.new
        # queue = sqs.queues.named('storm-generate-store-stats')
        # attributes = %w[store_key]
        # keys = []
        # queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
        #   keys << msg.message_attributes['store_key'][:string_value]
        # end

        # keys.uniq.each do |key|
        #   Rake::Task['stats:store:generate'].reenable
        #   Rake::Task['stats:store:generate'].all_prerequisite_tasks.each &:reenable
        #   Rake::Task['stats:store:generate'].invoke(key)
        # end
      end

      # }}}
    end
  end
end
