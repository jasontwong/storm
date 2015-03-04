namespace :stats do
  namespace :store do
    # {{{ desc "Store: Members"
    desc "Store: Members"
    task :members, [:key] do |t, args|
      begin
        query = "store_key:#{args[:key]} AND completed:true"
        response = @O_CLIENT.search("member_surveys", query, { limit: 100 })
        members = []
        loop do
          response.results.each do |survey|
            members << survey['value']['member_key']
          end

          response = response.next_results
          break if response.nil?
        end

        @O_CLIENT.patch('stores', args[:key], [
          { op: 'add', path: 'stats.members.submitted', value: members.uniq.length },
        ])
      rescue Orchestrate::API::BaseError => e
        puts e.inspect # Log orchestrate error
      end
    end
    # }}}
  end
end
