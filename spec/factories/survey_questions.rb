# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :survey_question do
    survey_id 1
    question { Faker::Lorem.sentence }
    answer_type { Faker::Lorem.word }
    answer_meta nil
    active false

    survey
  end
end
