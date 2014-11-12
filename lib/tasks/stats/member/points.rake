namespace :stats do
  namespace :member do
    namespace :points do
      # {{{ vars
      oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      # }}}
      # {{{ desc "Member: Points available"
      desc "Member: Points available"
      task :available, [:email] do |t, args|
        unless args[:email].nil?
          begin
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['points'] ||= {}
              data['points']['available'] = 0
              response = oclient.get_relations(:members, member.key, :points)
              loop do
                response.results.each { |point| data['points']['available'] += point['value']['current'] }
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
      # {{{ desc "Member: Points earned"
      desc "Member: Points earned"
      task :earned, [:email] do |t, args|
        unless args[:email].nil?
          begin
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['points'] ||= {}
              data['points']['earned'] = 0
              response = oclient.get_relations(:members, member.key, :points)
              loop do
                response.results.each { |point| data['points']['earned'] += point['value']['total'] }
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
