require 'spec_helper'

describe SurveyQuestionCategory do
  it 'has a valid factory' do
    FactoryGirl.build(:survey_question_category).should be_valid
  end
  it 'requires a name' do
    FactoryGirl.build(:survey_question_category, name: nil).should_not be_valid
  end
end
