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
    end
  end
end
