namespace :stats do
  namespace :member do
    # {{{ vars
    oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end

    # }}}
    # {{{ desc "Member: Surveys"
    desc "Member: Surveys"
    task :surveys, [:member] do |t, args|
      unless args[:member].nil?
        begin
          query = "member_key:#{args[:member]} AND completed:true"
          response = oclient.search(:member_surveys, query, { limit: 1 })
          oclient.patch('members', args[:member], [
            { op: 'add', path: 'stats.surveys.submitted', value: response.total_count || response.count }
          ])
        rescue Orchestrate::API::BaseError => e
          # Log orchestrate error
          puts e.inspect
        end
      end
    end

    # }}}
  end
end
