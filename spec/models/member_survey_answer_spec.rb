require 'rails_helper'

describe MemberSurveyAnswer do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member_survey_answer)).to be_valid
  end
  it 'requires a member_survey' do
    expect(FactoryGirl.build(:member_survey_answer, member_survey: nil)).not_to be_valid
  end
  it 'requires a question' do
    expect(FactoryGirl.build(:member_survey_answer, question: nil)).not_to be_valid
  end
end
