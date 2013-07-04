# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :member_survey do
    code_id 1
    member_id 1
    order_id 1
    company_id 1
    store_id 1
    completed false
    completed_time nil

    code
    member
    order
    company
    store
  end
end
