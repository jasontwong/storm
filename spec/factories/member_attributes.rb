# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member_attribute do
    member_id 1
    name { Faker::Lorem.word }
    value { Faker::Lorem.word }
    member
  end
end
