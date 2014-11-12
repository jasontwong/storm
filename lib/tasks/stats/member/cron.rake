namespace :stats do
  namespace :member do
    namespace :cron do
      # {{{ desc "Member: Nightly cronjob"
      desc "Member: Nightly cronjob"
      task :nightly do
        puts "Nightly"
      end

      # }}}
    end
  end
end
