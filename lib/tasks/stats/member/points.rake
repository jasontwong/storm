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
          points_available = 0
          points_earned = 0
          response = oclient.get_relations(:members, args[:member], :points)
          loop do
            response.results.each do |point|
              points_available += point['value']['current']
              points_earned += point['value']['total'] 
            end

            response = response.next_results
            break if response.nil?
          end

          oclient.patch('members', args[:member], [
            { op: 'add', path: 'stats.points.available', value: points_available },
            { op: 'add', path: 'stats.points.earned', value: points_earned }
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
