namespace :stats do
  namespace :member do
    namespace :points do
      # {{{ desc "Member: Points available"
      desc "Member: Points available"
      task :available, [:email] do |t, args|
        unless args[:email].nil?
          begin
            oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
            member = oclient.get(:members, args[:email])
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
      # {{{ desc "Member: Points earned"
      desc "Member: Points earned"
      task :earned, [:email] do |t, args|
        unless args[:email].nil?
          begin
            oclient = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY'])
            member = oclient.get(:members, args[:email])
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
            puts e.inspect
          end
        end
      end

      # }}}
    end
  end
end
