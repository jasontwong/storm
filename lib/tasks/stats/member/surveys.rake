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
    # {{{ desc "Member: Surveys"
    desc "Member: Surveys"
    task :surveys, [:email] do |t, args|
      unless args[:email].nil?
        begin
          query = "member_key:#{args[:email]} AND completed:true"
          response = oclient.search(:member_surveys, query, { limit: 1 })
          member = oapp[:members][args[:email]]
          member[:stats] ||= {}
          member[:stats]['surveys'] ||= {}
          member[:stats]['surveys']['submitted'] = response.total_count || response.count
          member.save!
        rescue Orchestrate::API::BaseError => e
          # Log orchestrate error
          puts e.inspect
        end
      end
    end

    # }}}
  end
end
