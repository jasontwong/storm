namespace :stats do
  namespace :member do
    namespace :rewards do
      # {{{ vars
      oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      # }}}
      # {{{ desc "Member: Rewards available"
      desc "Member: Rewards available"
      task :available, [:email] do |t, args|
        unless args[:email].nil?
          begin
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['rewards'] ||= {}
              data['rewards']['available'] = 0
              # TODO
              # Search over graph for all rewards > store > points
              # where member_key = member
              response = oclient.get_relations(:members, member.key, :points)
              loop do
                response.results.each do |point|
                  response2 = oclient.get_relations(:stores, point['value']['store_key'], :rewards)
                  loop do
                    response2.results.each do |reward|
                      data['rewards']['available'] += 1 if reward['value']['cost'] <= point['value']['current']
                    end
                    response2 = response2.next_results
                    break if response2.nil?
                  end
                end
                response = response.next_results
                break if response.nil?
              end
              member[:stats] = data
              member.save!
            end
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
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['rewards'] ||= {}
              query = "member_key:#{member.key}"
              response = oclient.search(:redeems, query, { limit: 1 })
              data['rewards']['redeemed'] = response.total_count || response.count
              member[:stats] = data
              member.save!
            end
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
