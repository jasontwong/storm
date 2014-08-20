# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :client do
    company_id 1
    email { Faker::Internet.email }
    password { Faker::Lorem.word }
    name { Faker::Name.name }
    salt { Faker::Lorem.word }
    active false

    company
  end

  factory :invalid_client, parent: :client do
    email nil
  end
end
