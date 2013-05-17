# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :company do
    name { Faker::Lorem.word }
    description { Faker::Lorem.word }
    logo { Faker::Lorem.word }
    location { Faker::Lorem.word }
    phone { Faker::Lorem.word }
  end

  factory :invalid_company, parent: :company do
    name nil
  end
end
