# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member_point, :class => 'MemberPoints' do
    member_id 1
    company_id 1
    points 10
    total_points 37
    last_earned { Time.now }

    member
    company
  end
end
