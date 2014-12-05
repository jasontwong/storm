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
      # {{{ desc "Member: Generate stats for members via SQS"
      desc "Member: Generate stats for members via SQS"
      task :sqs_stats do
        sqs = AWS::SQS.new
        queue = sqs.queues.named('storm-generate-member-stats')
        attributes = %w[member_key]
        keys = []
        queue.poll(idle_timeout: 5, message_attribute_names: attributes) do |msg|
          keys << msg.message_attributes['member_key'][:string_value]
        end

        keys.uniq.each do |key|
          Rake::Task['stats:member:generate'].reenable
          Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:generate'].invoke(key)
        end
      end

      # }}}
    end
  end
end
