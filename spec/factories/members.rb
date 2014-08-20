# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member do |f|
    f.email { Faker::Internet.email }
    f.salt { Faker::Lorem.word }
    f.password { Faker::Lorem.word }
    f.active true
  end

  factory :invalid_member, parent: :member do |f|
    f.email nil
  end
end
