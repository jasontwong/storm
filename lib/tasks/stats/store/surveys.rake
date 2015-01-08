namespace :stats do
  namespace :store do
    # {{{ vars
    oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    # }}}
    # {{{ desc "Store: Surveys"
    desc "Store: Surveys"
    task :surveys, [:key] do |t, args|
      begin
        query = "store_key:#{args[:key]} AND completed:true"
        response = oclient.search("member_surveys", query, { limit: 1 })
        oclient.patch('stores', args[:key], [
          { op: 'add', path: 'stats.surveys.submitted', value: response.total_count || response.count },
        ])
      rescue Orchestrate::API::BaseError => e
        puts e.inspect # Log orchestrate error
      end
    end
    # }}}
  end
end
