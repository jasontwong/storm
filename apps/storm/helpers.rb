require 'orchestrate'
require 'excon'

module Storm
  module Helpers
    extend self

    def modify_points(member, company, num)
      o_app = Orchestrate::Application.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end
      o_client = Orchestrate::Client.new(ENV['ORCHESTRATE_API_KEY']) do |conn|
        conn.adapter :excon
      end

      point_data = {
        current: 0,
        total: 0,
        member_key: member.key,
        company_key: company.key
      }

      point_data[:current] += num
      point_data[:total] += num if num > 0
      point_data[:last_earned] = Orchestrate::API::Helpers.timestamp(Time.now) if num > 0

      response = o_client.get_relations(:companies, company.key, :group)
      if response.count == 0
        company_keys = [company.key]
      else
        group = Orchestrate::KeyValue.from_listing(o_app[:company_groups], response.results.first, response)
        company_keys = group[:company_keys]
      end

      company_keys.each do |key|
        point_data[:company_key] = key
        query = "company_key:#{key} AND member_key:#{member.key}"
        response = o_client.search(:points, query)
        if response.count > 0
          points = Orchestrate::KeyValue.from_listing(o_app[:points], response.results.first, response)
          points[:current] += num
          points[:total] += num if num > 0
          points[:last_earned] = point_data[:last_earned] unless point_data[:last_earned].nil?
          points.save!
          points.key
        else
          # we couldn't find points that are associated with this key/member combination
          resp = o_client.post(:points, point_data)
          uri = URI(resp.location)
          path = uri.path.split("/")[2..-1]
          points_key = path[1]
          o_client.put_relation(:members, member.key, :points, :points, points_key)
          o_client.put_relation(:companies, key, :points, :points, points_key)
          points_key
        end
      end

    end

  end
end
