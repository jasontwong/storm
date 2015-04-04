require 'resque/errors'
require_relative 'retried_job'

class Event
  extend RetriedJob

  @queue = :event
  # {{{ def initialize(events)
  def initialize(events)
    @O_CLIENT = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
      conn.adapter :typhoeus
    end
    @events = events
  end

  # }}}
  # {{{ def self.perform(events)
  def self.perform(events)
    (new events).update_events
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  # }}}
  # {{{ def update_events
  def update_events
    @events.each do |data|
      begin
        data['keys'].each do |key|
          @O_CLIENT.post_event(data['collection'], key, data['event_name'], data['data'])
          flush "Adding Event #{data["event_name"]} to #{data["collection"]}"
        end
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
