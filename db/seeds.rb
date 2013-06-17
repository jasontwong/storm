# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'faker'

def random_num (decimal = false)
  round = decimal ? 2 : 0
  lambda { |min, max| rand * (max - min) + min }.call(100, 1).round(round)
end

# Rewards
# Companies
# Surveys

20.times do
  company = Company.create!(
    name: Faker::Company.name,
    logo: { 
      large: 'bigimage', 
      small: 'smallimage',
      bg: 'bgimage',
    },
    location: Faker::Address.street_address(true),
    phone: Faker::PhoneNumber.phone_number,
    survey_question_limit: 6,
  )
  20.times do |num|
    Store.create!(
      address1: Faker::Address.street_address,
      city: Faker::Address.city,
      company_id: company.id,
      country: Faker::Address.country,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      name: 'Store ' + num.to_s,
      phone: Faker::PhoneNumber.phone_number,
      state: Faker::Address.state,
      zip: Faker::Address.zip_code,
    )
    Product.create!(
      name: 'Product ' + num.to_s,
      price: random_num(true),
      company_id: company.id,
    )
  end
end
