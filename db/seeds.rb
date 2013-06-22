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

ApiKey.delete_all
ApiKey.create!(access_token: 'apikey')

20.times do
  company = Company.create!(
    name: Faker::Company.name,
    logo: { 
      large: 'bigimage', 
      small: 'smallimage',
      bg: 'bgimage',
    },
    description: Faker::Lorem.sentence,
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
    Reward.create!(
      company_id: company.id,
      cost: random_num,
      description: Faker::Lorem.sentence,
      title: Faker::Lorem.word,
    )
  end
end

20.times do
  member = Member.create!(
    email: Faker::Internet.email,
    salt: Faker::Lorem.word,
    other_id: Faker::Lorem.word,
    active: true,
  )
  password = Digest::SHA256.new
  password.update member.other_id
  member.password = BCrypt::Password.create(password.hexdigest + member.salt)

  Company.all.each do |company|
    points = random_num
    MemberPoints.create!(
      company_id: company.id,
      last_earned: Time.now.utc,
      member_id: member.id,
      points: points,
      total_points: points + random_num,
    )
  end

  member.save
end
