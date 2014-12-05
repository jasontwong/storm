namespace :stats do
  namespace :member do
    namespace :cron do
      # {{{ vars
      oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      # }}}
      # {{{ desc "Member: Generate stats for all"
      desc "Member: Generate stats for all"
      task :all_stats do
        members = oapp[:members]
        members.each do |member|
          Rake::Task['stats:member:generate'].reenable
          Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:generate'].invoke(member.key)
        end
      end

      # }}}
      # {{{ desc "Member: Generate places for all"
      desc "Member: Generate places for all"
      task :all_places do
        members = oapp[:members]
        members.each do |member|
          Rake::Task['stats:member:stores:places'].reenable
          Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:stores:places'].invoke(member.key)
        end
      end

      # }}}
      # {{{ desc "Member: Generate stats for members via SQS"
      desc "Member: Generate stats for members via SQS"
      task :sqs_stats do
        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-generate-member-stats')
        attributes = %w[member_key store_key]
        skeys = []
        mkeys = []
        queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
          mkey = msg.message_attributes['member_key'][:string_value]
          mkeys << mkey
          if msg.message_attributes.has_key? 'store_key'
            skey = msg.message_attributes['store_key'][:string_value]
            unless skeys.include? skey
              skeys << skey
              Rake::Task['stats:member:stores:places'].reenable
              Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
              Rake::Task['stats:member:stores:places'].invoke(mkey, skey)
            end
          end
        end

        mkeys.uniq.each do |mkey|
          Rake::Task['stats:member:generate'].reenable
          Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:generate'].invoke(mkey)
        end
      end

      # }}}
      # {{{ desc "Member: Visit SQS"
      desc "Member: Visit SQS"
      task :sqs_visited do
        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-member-visit')
        attributes = %w[member_key store_key]
        keys = []
        queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
          mkey = msg.message_attributes['member_key'][:string_value]
          skey = msg.message_attributes['store_key'][:string_value]
          unless keys.include? skey
            keys << skey
            Rake::Task['stats:member:stores:places'].reenable
            Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
            Rake::Task['stats:member:stores:places'].invoke(mkey, skey)
          end
        end
      end

      # }}}
    end
  end
end
