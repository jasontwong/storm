# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :store do
    name { Faker::Lorem.word }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip { Faker::Address.zip_code }
    country { Faker::Address.country }
    phone { Faker::PhoneNumber.phone_number }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    company
  end
end
