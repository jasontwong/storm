require 'resque/errors'
require_relative 'retried_job'

class Relation
  extend RetriedJob

  @queue = :relation
  # {{{ def initialize(relations)
  def initialize(relations)
    @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :excon
    end
    @relations = relations
  end

  # }}}
  # {{{ def self.perform(relations)
  def self.perform(relations)
    (new relations).update_relations
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  # }}}
  # {{{ def update_relations
  def update_relations
    @relations.each do |data|
      begin
        @O_CLIENT.put_relation(data["from_collection"], data["from_key"], data["from_name"], data["to_collection"], data["to_key"])
        flush "Adding Relation from #{data["from_collection"]} to #{data["to_collection"]}"
      rescue Orchestrate::API::BaseError => e
        flush "Performing #{self} caused an exception (#{e})."
      end
    end
  end

  # }}}
  # {{{ def flush(str)
  def flush(str)
    puts str
    $stdout.flush
  end
  
  # }}}
end
