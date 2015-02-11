namespace :stats do
  namespace :member do
    # {{{ desc "Member: Rewards"
    desc "Member: Rewards"
    multitask :rewards, [:member] => %w[rewards:available rewards:redeemed] do |t, args|
    end

    # }}}
    namespace :rewards do
      # {{{ desc "Member: Rewards available"
      desc "Member: Rewards available"
      task :available, [:member] do |t, args|
        unless args[:member].nil?
          begin
            rewards_available = 0
            places = @O_APP[:member_places][args[:member]]
            places['visited'].each { |place| rewards_available += place['rewards'].to_i } unless places.nil?
            @O_CLIENT.patch('members', args[:member], [
              { op: 'add', path: 'stats.rewards.available', value: rewards_available },
            ])
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
            puts e.inspect
          end
        end
      end

      # }}}
      # {{{ desc "Member: Rewards redeemed"
      desc "Member: Rewards redeemed"
      task :redeemed, [:member] do |t, args|
        unless args[:member].nil?
          begin
            query = "member_key:#{args[:member]}"
            response = @O_CLIENT.search(:redeems, query, { limit: 1 })
            member = @O_APP[:members][args[:member]]
            member.add('stats.rewards.redeemed', response.total_count || response.count)
              .update
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
