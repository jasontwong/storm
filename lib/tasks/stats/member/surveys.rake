namespace :stats do
  namespace :member do
    namespace :surveys do
      # {{{ vars
      oapp = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      # }}}
      # {{{ desc "Member: Surveys submitted"
      desc "Member: Surveys submitted"
      task :submitted, [:email] do |t, args|
        unless args[:email].nil?
          begin
            member = oapp[:members][args[:email]]
            unless member.nil?
              data = member[:stats] || {}
              data['surveys'] ||= {}
              query = "member_key:#{member.key} AND completed:true"
              response = oclient.search(:surveys, query, { limit: 1 })
              data['surveys']['submitted'] = response.total_count || response.count
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
