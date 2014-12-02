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

          keys.sort! { |a,b| b[:created_at] <=> a[:created_at] }
          member = oapp[:members][args[:email]]
          member[:stats] ||= {}
          member[:stats]['stores'] ||= {}
          member[:stats]['stores']['my_places'] = keys.uniq.collect { |key| key[:key] }
          member[:stats]['stores']['unique_visits'] = keys.uniq.length
          member[:stats]['stores']['visits'] = keys.length
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
