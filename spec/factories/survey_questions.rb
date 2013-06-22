# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :survey_question do
    company_id 1
    question { Faker::Lorem.sentence }
    answer_type { Faker::Lorem.word }
    answer_meta { { Faker::Lorem.word => Faker::Lorem.word } }
    active false
    dynamic false
    dynamic_meta { [{ Faker::Lorem.word => Faker::Lorem.word, Faker::Lorem.word => Faker::Lorem.word }] }

    company
  end

  factory :invalid_survey_question, parent: :survey_question do
    question nil
  end
end
