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
    # {{{ desc "Member: Rewards"
    desc "Member: Rewards"
    task :rewards, [:email] => %w[rewards:available rewards:redeemed] do |t, args|
    end

    # }}}
    namespace :rewards do
      # {{{ desc "Member: Rewards available"
      desc "Member: Rewards available"
      task :available, [:email] do |t, args|
        unless args[:email].nil?
          begin
            # TODO
            # Search over graph for all rewards > store > points
            # where member_key = member
            rewards_available = 0
            response = oclient.get_relations(:members, args[:email], :points)
            loop do
              response.results.each do |point|
                response2 = oclient.get_relations(:companies, point['value']['company_key'], :rewards)
                loop do
                  response2.results.each do |reward|
                    rewards_available += 1 if reward['value']['cost'].to_i <= point['value']['current'].to_i
                  end

                  response2 = response2.next_results
                  break if response2.nil?
                end
              end

              response = response.next_results
              break if response.nil?
            end

            member = oapp[:members][args[:email]]
            member[:stats] ||= {}
            member[:stats]['rewards'] ||= {}
            member[:stats]['rewards']['available'] = rewards_available
            member.save!
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
            puts e.inspect
          end
        end
      end

      # }}}
      # {{{ desc "Member: Rewards redeemed"
      desc "Member: Rewards redeemed"
      task :redeemed, [:email] do |t, args|
        unless args[:email].nil?
          begin
            query = "member_key:#{args[:email]}"
            response = oclient.search(:redeems, query, { limit: 1 })

            member = oapp[:members][args[:email]]
            member[:stats] ||= {}
            member[:stats]['rewards'] ||= {}
            member[:stats]['rewards']['redeemed'] = response.total_count || response.count
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
end
