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

5.times do
  company = Company.create!(
    name: Faker::Company.name,
    logo: { 
      large: 'bigimage', 
      small: 'smallimage',
      bg: 'bgimage',
      colors: {
        header: {
          r: random_num,
          g: random_num,
          b: random_num,
        },
        points: {
          r: random_num,
          g: random_num,
          b: random_num,
        },
        reward: {
          r: random_num,
          g: random_num,
          b: random_num,
        },
      },
    },
    description: Faker::Lorem.sentence,
    location: Faker::Address.street_address(true),
    phone: Faker::PhoneNumber.phone_number,
    survey_question_limit: 6,
    html: '<!DOCTYPE html><html><head></head><body></body><p style="text-align:center;">Yella <strong>bold</strong> <em>italic</em>!</p><p style="text-align:center;width:100%;">{QR}</p><div style="float:left;width:20%;">float left</div><div style="float:right;width:20%;">float right</div><div style="clear:both;">Cleared</div><div><p>Mongoose:</p><hr /><img src="http://www.enchantedlearning.com/ygifs/Yellowmongoose_bw.GIF" /></div><div><ul><li>A list item</li><li style="color:red;">Print red?</li><li><ul><li>A nested list item</li></ul></li></ul></div><table><tbody><tr><td>Support table cells?</td><td>Support table cells?</td></tr></tbody></table></html>',
  )
  5.times do |num|
    store = Store.create!(
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
    5.times do |num_a|
      survey = Survey.create!(
        title: "Survey Type " + num_a.to_s,
        store_id: store.id,
        description: Faker::Lorem.sentence,
        default: false,
      )
      10.times do |num_b|
        type = "slider"
        meta = { min: 0, max: 10 }
        if random_num % 2 == 0
          type = "switch"
          meta = { left: "No", right: "Yes" }
        end
        survey.survey_questions << SurveyQuestion.create!(
          question: "Question " + num_b.to_s + ": " + Faker::Lorem.sentence,
          answer_type: type,
          answer_meta: meta,
          active: true,
          company_id: company.id,
          dynamic: false,
          dynamic_meta: [],
        )
      end
      survey.save
    end
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

10.times do
  member = Member.create!(
    email: Faker::Internet.email,
    salt: Faker::Lorem.word,
    other_id: Faker::Lorem.word,
    active: true,
  )
  password = Digest::SHA256.new
  password.update member.other_id
  new_password = Digest::SHA256.new
  new_password.update password.hexdigest + member.salt
  member.password = new_password.hexdigest

  Company.all.each do |company|
    points = random_num
    MemberPoints.create!(
      company_id: company.id,
      last_earned: Time.now.utc,
      member_id: member.id,
      points: points,
      total_points: points + random_num,
    )
    company.stores.each do |store|
      10.times do
        code = Code.create!(
          qr: Faker::Lorem.characters,
          active: true,
          store_id: store.id,
        )
        order = Order.create!(
          code_id: code.id,
          company_id: company.id,
          store_id: store.id,
          amount: random_num(true),
          survey_worth: random_num(true),
          checkin_worth: random_num(true),
          server: Faker::Name.name,
        )
        2.times do
          product = company.products.offset(rand(company.products.count)).first
          OrderDetail.create!(
            order_id: order.id,
            product_id: product.id,
            name: product.name,
            quantity: random_num,
            discount: random_num(true),
            code_id: code.id,
            price: random_num(true),
          )
        end
      end
    end
  end

  member.save
end
