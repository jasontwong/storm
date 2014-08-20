require 'rails_helper'

describe SurveyQuestion do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:survey_question)).to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:survey_question, company: nil)).not_to be_valid
  end
  it 'requires a question' do
    expect(FactoryGirl.build(:survey_question, question: nil)).not_to be_valid
  end
  it 'requires a answer type' do
    expect(FactoryGirl.build(:survey_question, answer_type: nil)).not_to be_valid
  end
  it 'require active to be false if not true' do
    expect(FactoryGirl.build(:survey_question, active: 5)).active.to be_false
    expect(FactoryGirl.build(:survey_question, active: 'a')).active.to be_false
    expect(FactoryGirl.build(:survey_question, active: 1)).to be_valid
    expect(FactoryGirl.build(:survey_question, active: 0)).to be_valid
  end
  it 'require dynamic to be false if not true' do
    expect(FactoryGirl.build(:survey_question, dynamic: 5)).dynamic.to be_false
    expect(FactoryGirl.build(:survey_question, dynamic: 'a')).dynamic.to be_false
    expect(FactoryGirl.build(:survey_question, dynamic: 1)).to be_valid
    expect(FactoryGirl.build(:survey_question, dynamic: 0)).to be_valid
  end
  it 'requires answer_meta to be a Hash' do
    expect(FactoryGirl.create(:survey_question).answer_meta).to be_a(Hash)
  end
  it 'requires dynamic_meta to be a Array' do
    expect(FactoryGirl.create(:survey_question).dynamic_meta).to be_a(Array)
  end
  it 'requires a dynamic question to respond awesomeness' do
    question = FactoryGirl.create(:dynamic_survey_question)
    order = FactoryGirl.create(:order)
    product = FactoryGirl.create(:product, name: 'Product 1')
    code = FactoryGirl.create(:code, order: order)
    order_detail = FactoryGirl.create(:order_detail, code: code, order: order, name: 'prod-1', product: product, price: 99)

    q1 = question.build_question(code)
    expect(q1).to eq('This is a dynamic question: Product 1')

    product = FactoryGirl.create(:product, id: 3, name: 'Product 3')
    order_detail = FactoryGirl.create(:order_detail, code: code, order: order, name: 'prod-3', product: product, price: 9999)

    q2 = question.build_question(code)
    expect(q2).to eq('This is a dynamic question: Product 3')

    product = FactoryGirl.create(:product, id: 7, name: 'Product 7')
    order_detail = FactoryGirl.create(:order_detail, code: code, order: order, name: 'prod-3', product: product, price: 999)

    q3 = question.build_question(code)
    expect(q3).not_to eq('This is a dynamic question: Product 7')
  end
end
