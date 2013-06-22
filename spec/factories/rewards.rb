# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  sequence(:rand) { |n| lambda { |min, max| rand * (max - min) + min }.call(100, 1).round(0) }
  factory :reward do
    company_id 1
    title { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    cost { FactoryGirl.generate(:rand) }
    starts { FactoryGirl.generate(:rand).month.ago }
    expires { FactoryGirl.generate(:rand).month.from_now }
    uses_left { FactoryGirl.generate(:rand) }
    images { { Faker::Lorem.word => Faker::Lorem.word } }

    company
  end

  factory :invalid_reward, parent: :reward do
    title nil
  end
end
