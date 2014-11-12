namespace :stats do
  namespace :member do
    namespace :surveys do
      # {{{ desc "Member: Surveys submitted"
      desc "Member: Surveys submitted"
      task :submitted, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          begin
            data = member[:stats] || {}
            data[:surveys] ||= {}
            data[:surveys][:submitted] = 0
            # TODO
            # search over graph when available
            member.relations[:surveys].each do |survey|
              data[:surveys][:submitted] += 1 if survey[:completed]
            end
            member[:stats] = data
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
