namespace :stats do
  namespace :member do
    namespace :points do
      # {{{ desc "Member: Points earned"
      desc "Member: Points earned"
      task :earned, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          begin
            data = member[:stats] || {}
            data[:points] ||= {}
            data[:points][:earned] = 0
            member.relations[:points].each do |point|
              data[:points][:earned] += point[:total]
            end
            member[:stats] = data
            member.save!
          rescue Orchestrate::API::BaseError => e
            # Log orchestrate error
          end
        end
      end

      # }}}
      # {{{ desc "Member: Points available"
      desc "Member: Points available"
      task :available, [:members] do |t, args|
        args.with_defaults(:members => [])
        args[:members].each do |member|
          begin
            data = member[:stats] || {}
            data[:points] ||= {}
            data[:points][:available] = 0
            member.relations[:points].each do |point|
              data[:points][:available] += point[:current]
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
