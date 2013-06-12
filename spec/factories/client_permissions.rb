# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :client_permission do
    name { Faker::Name.name }
  end
end
