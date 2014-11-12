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
      # {{{ desc "Member: Nightly cronjob"
      desc "Member: Nightly cronjob"
      task :nightly do
        members = @O_APP[:members]
        members.each do
          Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:generate'].invoke(member.key)
        end
      end

      # }}}
    end
  end
end
