require 'resque/errors'
require_relative 'retried_job'

class Stat
  extend RetriedJob

  @queue = :stat
  # {{{ def initialize(stats)
  def initialize(stats)
    @stats = stats
  end

  # }}}
  # {{{ def self.perform(stats)
  def self.perform(stats)
    (new stats).update_stats
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  # }}}
  # {{{ def update_stats
  def update_stats
    begin
      generate_member_places(@stats['mkey'], @stats['skey'])
      generate_member_stats(@stats['mkey'])
      generate_store_stats(@stats['skey'])
      flush "Adding Stat #{@stats["type"]}"
    rescue Orchestrate::API::BaseError => e
      flush "Performing #{self} caused an exception (#{e})."
    end
  end

  # }}}
  # {{{ def generate_member_places(mkey, skey)
  def generate_member_places(mkey, skey)
    Rake::Task['stats:member:stores:places'].reenable
    Rake::Task['stats:member:stores:places'].all_prerequisite_tasks.each &:reenable
    Rake::Task['stats:member:stores:places'].invoke(mkey, skey)
  end

  # }}}
  # {{{ def generate_member_stats(mkey)
  def generate_member_stats(mkey)
    Rake::Task['stats:member:generate'].reenable
    Rake::Task['stats:member:generate'].all_prerequisite_tasks.each &:reenable
    Rake::Task['stats:member:generate'].invoke(mkey)
  end

  # }}}
  # {{{ def generate_store_stats(skey)
  def generate_store_stats(skey)
    Rake::Task['stats:store:generate'].reenable
    Rake::Task['stats:store:generate'].all_prerequisite_tasks.each &:reenable
    Rake::Task['stats:store:generate'].invoke(skey)
  end

  # }}}
end
