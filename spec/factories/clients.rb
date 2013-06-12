# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :client do
    company_id 1
    email { Faker::Internet.email }
    password { Faker::Lorem.word }
    client_group_id 1
    name { Faker::Name.name }
    salt { Faker::Lorem.word }
    active false

    company
    client_group
  end

  factory :invalid_client, parent: :client do
    email nil
  end
end
