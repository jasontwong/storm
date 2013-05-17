# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :product do
    name { Faker::Name.name }
    price { lambda { |min, max| rand * (max - min) + min }.call(100, 1).round(2) }
    size { Faker::Lorem.word }
    company_id 1
    company
  end

  factory :invalid_product, parent: :product do
    name nil
  end
end
