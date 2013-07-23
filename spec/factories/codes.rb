# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :code do
    qr { Faker::Lorem.word }
    used 0
    active true
    last_used_time { Time.now.to_i }
    store_id 1

    store
  end

  factory :invalid_code, parent: :code do
    qr nil
  end
end
