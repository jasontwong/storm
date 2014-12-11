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
    task :stores, [:email] do |t, args|
      unless args[:email].nil?
        begin
          keys = []
          response = oclient.get_relations(:members, args[:email], :checkins)
          loop do
            response.results.each do |survey|
              keys << {
                key: survey['value']['store_key'],
                created: survey['value']['created_at'], 
              }
            end

            response = response.next_results
            break if response.nil?
          end

          u_visits = keys.uniq { |k| k[:key] }.sort { |a,b| b[:created_at] <=> a[:created_at] }
          member = oapp[:members][args[:email]]
          member[:stats] ||= {}
          member[:stats]['stores'] ||= {}
          member[:stats]['stores']['unique_visits'] = u_visits.length
          member[:stats]['stores']['visits'] = keys.length
          member.save!
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
      task :places, [:email, :store] do |t, args|
        unless args[:email].nil?
          begin
            keys = []
            query = "member_key:#{args[:email]}"
            options = {
              limit: 100,
              sort: 'created_at:desc'
            }
            unless args[:store].nil?
              query += "AND store_key:#{args[:store]}"
              options[:limit] = 1
            end
            response = oclient.search(:checkins, query, options)
            loop do
              response.results.each do |survey|
                keys << {
                  key: survey['value']['store_key'],
                  created_at: survey['value']['created_at']
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
              response = oclient.get_relations(:stores, store[:key], :company)
              unless response.results.empty?
                company = response.results.first
                company_key = company['path']['key']
                if companies.has_key? company_key
                  data = companies[company_key]
                else
                  query = "company_key:#{company_key} AND member_key:#{args[:email]}"
                  response = oclient.search(:points, query, { limit: 1 })
                  unless response.results.empty?
                    points = response.results.first
                    data['points'] = points['value']['current']
                    response = oclient.get_relations(:companies, company_key, :rewards)
                    loop do
                      response.results.each { |rw| data['rewards'] += 1 if rw['value']['cost'].to_i <= data[:points].to_i }
                      response = response.next_results
                      break if response.nil?
                    end
                  end

                  companies[company_key] = data
                end

                data['last_visited_at'] = store[:created_at]
                data['company_key'] = company_key
                data['store_key'] = store[:key]
                places << data
              end
            end

            m_places = oapp[:member_places][args[:email]]
            if m_places.nil?
              m_places = oapp[:member_places].create(args[:email], { visited: places.sort{|a,b| b['last_visited_at'] <=> a['last_visited_at']} })
            else
              found = []
              places.each do |place|
                new_places = m_places['visited'].select { |old_place| old_place['company_key'] == place['company_key'] }
                new_places.each do |new_place|
                  new_place['rewards'] = place['rewards']
                  new_place['points'] = place['points']
                end
                found += new_places
              end
              places = (found + places).group_by{|h| h['store_key']}.map{|k,v| v.reduce(:merge)}.sort{|a,b| b['last_visited_at'] <=> a['last_visited_at']}
              m_places[:visited] = (m_places[:visited] + places).group_by{|h| h['store_key']}.map{|k,v| v.reduce(:merge)}.sort{|a,b| b['last_visited_at'] <=> a['last_visited_at']}
              m_places.save!
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
