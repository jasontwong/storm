# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :survey do
    company_id 1
    title { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    default false

    company
  end

  factory :invalid_survey, parent: :survey do
    title nil
  end
end
