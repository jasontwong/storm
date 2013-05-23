# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member_answer do
    member_id 1
    code_id 1
    question { Faker::Lorem.sentence }
    answer { Faker::Lorem.sentence }
    completed false
    completed_time { Time.now }

    member
    code
  end
end
