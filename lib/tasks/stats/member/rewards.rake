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
              member.relations[:points].each do |point|
                response = oclient.get_relations(:stores, point[:store_key], :rewards)
                response.results.each do |reward|
                  data['rewards']['available'] += 1 if reward['value']['cost'] <= point[:current]
                end
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
              response = oclient.get_relations(:members, member.key, :redeemed)
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
