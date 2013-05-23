# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  sequence(:rand_d) { |n| lambda { |min, max| rand * (max - min) + min }.call(100, 1).round(2) }
  factory :order do
    member_id 1
    code_id 1
    company_id 1
    store_id 1
    amount { FactoryGirl.generate(:rand_d) }
    survey_worth { FactoryGirl.generate(:rand_d) }
    checkin_worth { FactoryGirl.generate(:rand_d) }
    server { Faker::Name.name }

    company
    store
    code
    member
  end

  factory :invalid_order, parent: :order do
    survey_worth nil
  end
end
