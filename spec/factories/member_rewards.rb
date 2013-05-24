# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :member_reward do
    member_id 1
    reward_id 1
    redeemed false
    store_id 1
    printed 0
    scanned 0
    code { Faker::Lorem.word }
    bcode ""
    redeemed_time { 5.days.from_now }

    member
    reward
    store
  end
end
