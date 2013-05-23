require 'spec_helper'

describe SurveyQuestion do
  it 'has a valid factory' do
    FactoryGirl.build(:survey_question).should be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:survey_question, company: nil).should_not be_valid
  end
  it 'requires a question' do
    FactoryGirl.build(:survey_question, question: nil).should_not be_valid
  end
  it 'requires a answer type' do
    FactoryGirl.build(:survey_question, answer_type: nil).should_not be_valid
  end
  it 'require active to be false if not true' do
    FactoryGirl.build(:survey_question, active: 5).active.should be_false
    FactoryGirl.build(:survey_question, active: 'a').active.should be_false
    FactoryGirl.build(:survey_question, active: 1).should be_valid
    FactoryGirl.build(:survey_question, active: 0).should be_valid
  end
  it 'require dynamic to be false if not true' do
    FactoryGirl.build(:survey_question, dynamic: 5).dynamic.should be_false
    FactoryGirl.build(:survey_question, dynamic: 'a').dynamic.should be_false
    FactoryGirl.build(:survey_question, dynamic: 1).should be_valid
    FactoryGirl.build(:survey_question, dynamic: 0).should be_valid
  end
  it 'requires answer_meta to be a Hash' do
    FactoryGirl.create(:survey_question).answer_meta.should be_a(Hash)
  end
  it 'requires dynamic_meta to be a Hash' do
    FactoryGirl.create(:survey_question).dynamic_meta.should be_a(Array)
  end
end
