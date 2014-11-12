namespace :stats do
  namespace :member do
    namespace :stores do
      # {{{ desc "Member: Store visits"
      desc "Member: Store visits"
      task :visits, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          oclient ||= Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
          begin
            data = member[:stats] || {}
            data[:stores] ||= {}
            response = oclient.get_relations(:members, member.key, :surveys)
            data[:stores][:visits] = response.total_count || response.count
            member[:stats] = data
            member.save!
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
          end
        end
      end

      # }}}
      # {{{ desc "Member: Store unique visits"
      desc "Member: Store unique visits"
      task :unique_visits, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          oclient ||= Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
          begin
            data = member[:stats] || {}
            data[:stores] ||= {}
            response = oclient.get_relations(:members, member.key, :points)
            data[:stores][:unique_visits] = response.total_count || response.count
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
