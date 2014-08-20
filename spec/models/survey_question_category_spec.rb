require 'rails_helper'

describe SurveyQuestionCategory do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:survey_question_category)).to be_valid
  end
  it 'requires a name' do
    expect(FactoryGirl.build(:survey_question_category, name: nil)).not_to be_valid
  end
end
