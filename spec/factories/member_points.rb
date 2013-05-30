# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member_point, :class => 'MemberPoints' do
    member_id 1
    company_id 1
    points { FactoryGirl.generate(:rand_d) }
    total_points { points + 5 }
    last_earned { Time.now }

    member
    company
  end
end
