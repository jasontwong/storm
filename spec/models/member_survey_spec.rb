require 'spec_helper'

describe MemberSurvey do
  it 'has a valid factory' do
    FactoryGirl.build(:member_survey).should be_valid
  end
  it 'requires a code' do
    FactoryGirl.build(:member_survey, code: nil).should_not be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:member_survey, company: nil).should_not be_valid
  end
  it 'requires a member' do
    FactoryGirl.build(:member_survey, member: nil).should_not be_valid
  end
  it 'requires a order' do
    FactoryGirl.build(:member_survey, order: nil).should_not be_valid
  end
  it 'requires a store' do
    FactoryGirl.build(:member_survey, store: nil).should_not be_valid
  end
end
