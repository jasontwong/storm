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
        tp = ThreadPool.new(10)
        stores = oapp[:stores]
        stores.each do |store|
          tp.schedule(store) do |store|
            Rake::Task['stats:store:generate'].reenable
            Rake::Task['stats:store:generate'].all_prerequisite_tasks.each &:reenable
            Rake::Task['stats:store:generate'].invoke(store.key)
          end
        end

        at_exit { tp.shutdown }
      end

      # }}}
    end
  end
end
