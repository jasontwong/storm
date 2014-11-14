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
    task :points , [:email] do |t, args|
      unless args[:email].nil?
        begin
          points_available = 0
          points_earned = 0
          response = oclient.get_relations(:members, args[:email], :points)
          loop do
            response.results.each do |point|
              points_available += point['value']['current']
              points_earned += point['value']['total'] 
            end
            response = response.next_results
            break if response.nil?
          end

          member = oapp[:members][args[:email]]
          member[:stats] ||= {}
          member[:stats]['points'] ||= {}
          member[:stats]['points']['available'] = points_available
          member[:stats]['points']['earned'] = points_earned
          member.save!
        rescue Orchestrate::API::BaseError => e
          # Log orchestrate error
          puts e.inspect
        end
      end
    end

    # }}}
  end
end
