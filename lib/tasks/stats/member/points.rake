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
    # {{{ desc "Member: Points"
    desc "Member: Points"
    task :points , [:member] do |t, args|
      unless args[:member].nil?
        begin
          query = "member_key:#{args[:member]}"
          options = {
            aggregate: "current:stats,total:stats"
          }
          available = response.aggregates.first['statistics']
          earned = response.aggregates.last['statistics']
          response = oclient.search(:points, query, options)
          oclient.patch('members', args[:member], [
            { op: 'add', path: 'stats.points.available', value: available ? available['sum'] : 0},
            { op: 'add', path: 'stats.points.earned', value: earned ? earned['sum'] : 0},
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
