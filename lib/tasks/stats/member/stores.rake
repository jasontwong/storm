namespace :stats do
  namespace :member do
    namespace :stores do
      # {{{ vars
      oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      # }}}
      # {{{ desc "Member: Store unique visits"
      desc "Member: Store unique visits"
      task :unique_visits, [:email] do |t, args|
        unless args[:email].nil?
          begin
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['stores'] ||= {}
              data['stores']['unique_visits'] = 0
              response = oclient.get_relations(:members, member.key, :surveys)
              keys = []
              loop do
                response.results.each { |survey| keys << survey['value']['store_key'] }
                response = response.next_results
                break if response.nil?
              end
              data['stores']['unique_visits'] = keys.uniq.length
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
      # {{{ desc "Member: Store visits"
      desc "Member: Store visits"
      task :visits, [:email] do |t, args|
        unless args[:email].nil?
          begin
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['stores'] ||= {}
              data['stores']['visits'] = 0
              response = oclient.get_relations(:members, member.key, :surveys)
              loop do
                response.results.each { |survey| data['stores']['visits'] += 1 }
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
    end
  end
end
