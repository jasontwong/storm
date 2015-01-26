require 'resque/errors'
require_relative 'retried_job'

class Stat
  extend RetriedJob

  @queue = :stat
  def initialize(stats)
    @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    @stats = stats
  end

  def self.perform(stats)
    (new stats).update_stats
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  def update_stats
      begin
        case @stats['type']
        when 'checkin'
          Rake::Task['stats:member:stores:places'].reenable
          Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:stores:places'].invoke(@stats['mkey'], @stats['skey'])
          Rake::Task['stats:member:generate'].reenable
          Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
          Rake::Task['stats:member:generate'].invoke(@stats['mkey'], @stats['skey'])
        end
        flush "Adding Stat #{@stats["type"]}"
      rescue Orchestrate::API::BaseError => e
        flush "Performing #{self} caused an exception (#{e})."
      end
  end

  def flush(str)
    puts str
    $stdout.flush
  end
end
