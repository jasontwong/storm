namespace :stats do
  namespace :user do
    namespace :surveys do
      # {{{ desc "User: Surveys submitted"
      desc "User: Surveys submitted"
      task :submitted, [:emails] do |t, args|
        args.with_defaults(:emails => [])
        oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
        args[:emails].each do |email|
          begin
            member = oclient.get(:members, email)
            data = member[:stats] || {}
            data[:surveys] ||= {}
            data[:surveys][:submitted] = 0
            member.relations[:surveys].each do |survey|
              data[:surveys][:submitted] += 1 if survey[:completed]
            end
            member.save!
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
          end
        end
      end

      # }}}
    end
  end
end
