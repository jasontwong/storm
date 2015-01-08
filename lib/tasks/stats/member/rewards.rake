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
            places = oapp[:member_places][args[:member]]
            places['visited'].each { |place| rewards_available += place['rewards'].to_i } unless places.nil?
            oclient.patch('members', args[:member], [
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
            response = oclient.search(:redeems, query, { limit: 1 })
            member = oapp[:members][args[:member]]
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
