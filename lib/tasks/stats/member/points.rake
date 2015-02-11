namespace :stats do
  namespace :member do
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
          response = @O_CLIENT.search(:points, query, options)
          @O_CLIENT.patch('members', args[:member], [
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
