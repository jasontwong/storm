namespace :stats do
  namespace :member do
    # {{{ desc "Member: Surveys"
    desc "Member: Surveys"
    task :surveys, [:member] do |t, args|
      unless args[:member].nil?
        begin
          query = "member_key:#{args[:member]} AND completed:true"
          response = @O_CLIENT.search(:member_surveys, query, { limit: 1 })
          @O_CLIENT.patch('members', args[:member], [
            { op: 'add', path: 'stats.surveys.submitted', value: response.total_count || response.count }
          ])
        rescue Orchestrate::API::BaseError => e
          # Log orchestrate error
          puts e.inspect
        end
      end
    end

    # }}}
  end
end
