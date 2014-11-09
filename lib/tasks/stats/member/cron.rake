namespace :stats do
  namespace :member do
    namespace :cron do
      # {{{ desc "Member: Nightly cronjob" do
      desc "Member: Nightly cronjob" do
      task :nightly do
        puts "Nightly"
      end

      # }}}
    end
  end
end
