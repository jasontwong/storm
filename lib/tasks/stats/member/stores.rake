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
    # {{{ desc "Member: Stores"
    desc "Member: Stores"
    task :stores, [:member] do |t, args|
      unless args[:member].nil?
        begin
          keys = []
          response = oclient.get_relations(:members, args[:member], :checkins)
          loop do
            response.results.each do |checkin|
              keys << {
                key: checkin['value']['store_key'],
                created: checkin['value']['created_at'], 
              }
            end

            response = response.next_results
            break if response.nil?
          end

          u_visits = keys.uniq { |k| k[:key] }
          oclient.patch('members', args[:member], [
            { op: 'add', path: 'stats.stores.unique_visits', value: u_visits.length },
            { op: 'add', path: 'stats.stores.visits', value: keys.length },
          ])
        rescue Orchestrate::API::BaseError => e
          # Log orchestrate error
          puts e.inspect
        end
      end
    end

    # }}}
    namespace :stores do
      # {{{ desc "Member: Stores Places"
      desc "Member: Stores Places"
      task :places, [:member, :store] do |t, args|
        unless args[:member].nil?
          begin
            keys = []
            query = "member_key:#{args[:member]}"
            m_places = oapp[:member_places][args[:member]]
            unless m_places.nil? || m_places[:last_updated_at].nil?
              query += " AND created_at:[#{m_places[:last_updated_at]} TO *]"
            end

            options = {
              limit: 100,
              sort: 'created_at:desc'
            }
            unless args[:store].nil?
              query += " AND store_key:#{args[:store]}"
              options[:limit] = 1
            end

            response = oclient.search(:checkins, query, options)
            loop do
              response.results.each do |checkin|
                keys << {
                  key: checkin['value']['store_key'],
                  company_key: checkin['value']['company_key'],
                  created_at: checkin['value']['created_at']
                }
              end

              response = response.next_results
              break if response.nil? || options[:limit] == 1
            end

            keys.uniq! { |k| k[:key] }
            places = []
            companies = {}
            keys.each do |store|
              data = {
                'points' => 0,
                'rewards' => 0
              }
              company_key = store[:company_key]
              if companies.has_key? company_key
                data = companies[company_key]
              else
                query = "company_key:#{company_key} AND member_key:#{args[:member]}"
                response = oclient.search(:points, query, { limit: 1 })
                unless response.results.empty?
                  points = response.results.first
                  data['points'] = points['value']['current']
                  query = "company_key:#{company_key} AND cost:[0 TO #{data['points']}]"
                  response = oclient.search(:rewards, query)
                  data['rewards'] = response.total_count || response.count
                end

                companies[company_key] = data
              end

              data['last_visited_at'] = store[:created_at]
              data['company_key'] = company_key
              data['store_key'] = store[:key]
              places << data
            end

            if m_places.nil?
              visited = places.sort{ |a,b| b['last_visited_at'] <=> a['last_visited_at'] }
              m_places = oapp[:member_places].create(args[:member], {
                visited: visited,
                last_updated_at: visited.first['last_visited_at']
              })
            elsif !places.empty?
              visited = (m_places['visited'] + places).group_by{|h| h['store_key']}.map{|k,v| v.reduce(:merge)}.sort{|a,b| b['last_visited_at'] <=> a['last_visited_at']}
              m_places
                .add('visited', visited)
                .add('last_updated_at', visited.first['last_visited_at'])
                .update
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
