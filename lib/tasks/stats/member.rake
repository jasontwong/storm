namespace :stats do
  namespace :member do
    # {{{ desc "Generate stats for all members"
    desc "Generate stats for all members"
    task :generate do
      puts "Generate stats"
      # oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY'])
      # Rake::Task['stats:member:surveys:submitted'].invoke
    end

    # }}}
  end
end
