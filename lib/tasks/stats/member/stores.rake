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
    multitask :stores, [:email] do |t, args|
      unless args[:email].nil?
        begin
          keys = []
          response = oclient.get_relations(:members, args[:email], :surveys)
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

          places = []
          companies = {}
          u_visits.each do |store|
            data = {}
            response = oclient.get_relations(:stores, store[:key], :company)
            unless response.results.empty?
              company = response.results.first
              query = "company_key:#{company['path']['key']} AND member_key:#{args[:email]}"
              response = oclient.search(:points, query, { limit: 1 })
              unless response.results.empty?
                points = response.results.first
                data[:points] = points['value']['current']
                data[:rewards] = 0
                if companies.has_key? company['path']['key']
                  data = companies[company['path']['key']]
                else
                  response = oclient.get_relations(:companies, company['path']['key'], :rewards)
                  loop do
                    response.results.each do |rw|
                      data[:rewards] += 1 if rw[:cost].to_i <= data[:points].to_i
                    end
                    response = response.next_results
                    break if response.nil?
                  end
                  companies[company['path']['key']] = data
                end
                data[:store_key] = store[:key]
                places << data
              end
            end
          end

          m_places = oapp[:member_places][args[:email]]
          m_places = oapp[:member_places].create(args[:email], {}) if m_places.nil?
          m_places[:visited] = places
          m_places.save!
        rescue Orchestrate::API::BaseError => e
          # Log orchestrate error
          puts e.inspect
        end
      end
    end

    # }}}
  end
end
