# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :changelog do
    type ""
    model "MyString"
    meta "MyText"
  end
end
