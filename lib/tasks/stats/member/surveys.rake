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
              data['surveys']['submitted'] = 0
              # TODO
              # search over graph when available
              member.relations[:surveys].each do |survey|
                data['surveys']['submitted'] += 1 if survey[:completed]
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
