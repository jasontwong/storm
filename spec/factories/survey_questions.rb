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

  factory :dynamic_survey_question, parent: :survey_question do
    question 'This is a dynamic question: %s'
    active true
    dynamic true
    dynamic_meta { [ { product_ids: [1,3,7] } ] }
  end

  factory :invalid_survey_question, parent: :survey_question do
    question nil
  end
end
