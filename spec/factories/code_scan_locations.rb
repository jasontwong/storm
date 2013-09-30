# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :code_scan_location do
    latitude "9.99"
    longitude "9.99"
    member_id 1
    code_id 1
  end
end
