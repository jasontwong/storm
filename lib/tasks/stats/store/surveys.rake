namespace :stats do
  namespace :store do
    # {{{ desc "Store: Surveys"
    desc "Store: Surveys"
    task :surveys, [:key] do |t, args|
      begin
        query = "store_key:#{args[:key]} AND completed:true"
        response = @O_CLIENT.search("member_surveys", query, { limit: 1 })
        @O_CLIENT.patch('stores', args[:key], [
          { op: 'add', path: 'stats.surveys.submitted', value: response.total_count || response.count },
        ])
      rescue Orchestrate::API::BaseError => e
        puts e.inspect # Log orchestrate error
      end
    end
    # }}}
  end
end
