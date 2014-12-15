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
        tp = ThreadPool.new(10)
        members = oapp[:members]
        members.each do |member|
          tp.schedule(member) do |member|
            Rake::Task['stats:member:generate'].reenable
            Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
            Rake::Task['stats:member:generate'].invoke(member.key)
          end
        end

        at_exit { tp.shutdown }
      end

      # }}}
      # {{{ desc "Member: Generate places for all"
      desc "Member: Generate places for all"
      task :all_places do
        tp = ThreadPool.new(10)
        members = oapp[:members]
        members.each do |member|
          tp.schedule(member) do |member|
            Rake::Task['stats:member:stores:places'].reenable
            Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
            Rake::Task['stats:member:stores:places'].invoke(member.key)
          end
        end

        at_exit { tp.shutdown }
      end

      # }}}
      # {{{ desc "Member: Generate stats for members via SQS"
      desc "Member: Generate stats for members via SQS"
      task :sqs_stats do
        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-generate-member-stats')
        attributes = %w[member_key store_key]
        keys = {}
        mkeys = []
        queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
          mkey = msg.message_attributes['member_key'][:string_value]
          mkeys << mkey
          keys[mkey] ||= []
          skey = msg.message_attributes['store_key'][:string_value]
          unless keys[mkey].include? skey
            keys[mkey] << skey
            Rake::Task['stats:member:stores:places'].reenable
            Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
            Rake::Task['stats:member:stores:places'].invoke(mkey, skey)
          end
        end

        tp = ThreadPool.new(10)
        mkeys.uniq.each do |mkey|
          tp.schedule(mkey) do |mkey|
            Rake::Task['stats:member:generate'].reenable
            Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
            Rake::Task['stats:member:generate'].invoke(mkey)
          end
        end

        at_exit { tp.shutdown }
      end

      # }}}
      # {{{ desc "Member: Visit SQS"
      desc "Member: Visit SQS"
      task :sqs_visited do
        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-member-visit')
        attributes = %w[member_key store_key]
        keys = {}
        queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
          mkey = msg.message_attributes['member_key'][:string_value]
          keys[mkey] ||= []
          skey = msg.message_attributes['store_key'][:string_value]
          unless keys[mkey].include? skey
            keys[mkey] << skey
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
