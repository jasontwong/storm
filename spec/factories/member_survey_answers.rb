# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member_survey_answer do
    member_survey_id 1
    question { Faker::Lorem.sentence }
    answer { Faker::Lorem.sentence }

    member_survey
  end
end
