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
    expect(FactoryGirl.build(:survey_question, active: 5).active).to be_falsey
    expect(FactoryGirl.build(:survey_question, active: 'a').active).to be_falsey
    expect(FactoryGirl.build(:survey_question, active: 1)).to be_valid
    expect(FactoryGirl.build(:survey_question, active: 0)).to be_valid
  end
  it 'require dynamic to be false if not true' do
    expect(FactoryGirl.build(:survey_question, dynamic: 5).dynamic).to be_falsey
    expect(FactoryGirl.build(:survey_question, dynamic: 'a').dynamic).to be_falsey
    expect(FactoryGirl.build(:survey_question, dynamic: 1)).to be_valid
    expect(FactoryGirl.build(:survey_question, dynamic: 0)).to be_valid
  end
  it 'requires answer_meta to be a Hash' do
    expect(FactoryGirl.create(:survey_question).answer_meta).to be_a(Hash)
  end
  it 'requires dynamic_meta to be a Array' do
    expect(FactoryGirl.create(:survey_question).dynamic_meta).to be_a(Array)
  end
end
