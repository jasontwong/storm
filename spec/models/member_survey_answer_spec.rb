require 'spec_helper'

describe MemberSurveyAnswer do
  it 'has a valid factory' do
    FactoryGirl.build(:member_survey_answer).should be_valid
  end
  it 'requires a member_survey' do
    FactoryGirl.build(:member_survey_answer, member_survey: nil).should_not be_valid
  end
  it 'requires a question' do
    FactoryGirl.build(:member_survey_answer, question: nil).should_not be_valid
  end
end
