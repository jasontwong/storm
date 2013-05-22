# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :survey_question_category do
    name { Faker::Lorem.word }
  end
end
