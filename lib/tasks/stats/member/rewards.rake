namespace :stats do
  namespace :member do
    namespace :rewards do
      # {{{ desc "Member: Rewards available"
      desc "Member: Rewards available"
      task :available, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          oclient ||= Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
          begin
            data = member[:stats] || {}
            data[:rewards] ||= {}
            data[:rewards][:available] = 0
            member.relations[:points].each do |point|
              response = oclient.get_relations(:stores, point[:store_key], :rewards)
              response.results.each do |reward|
                data[:rewards][:available] += 1 if reward['value']['cost'] <= point[:current]
              end
            end
            member[:stats] = data
            member.save!
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
          end
        end
      end

      # }}}
      # {{{ desc "Member: Rewards redeemed"
      desc "Member: Rewards redeemed"
      task :redeemed, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          oclient ||= Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
          begin
            data = member[:stats] || {}
            data[:rewards] ||= {}
            response = oclient.get_relations(:members, member.key, :redeemed)
            data[:rewards][:redeemed] = response.total_count || response.count
            member[:stats] = data
            member.save!
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
          end
        end
      end

      # }}}
    end
  end
end
