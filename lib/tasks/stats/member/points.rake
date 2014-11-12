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
              member.relations[:points].each do |point|
                data['points']['available'] += point[:current]
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
              member.relations[:points].each do |point|
                data['points']['earned'] += point[:total]
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
