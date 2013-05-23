# Read about factories at https://github.com/thoughtbot/factory_girl
require 'faker'

FactoryGirl.define do
  factory :order_detail do
    order_id 1
    product_id 1
    name { Faker::Lorem.word }
    quantity { FactoryGirl.generate(:rand) }
    discount { FactoryGirl.generate(:rand_d) }
    code_id 1
    price { FactoryGirl.generate(:rand_d) }

    order
    product
    code
  end
end
