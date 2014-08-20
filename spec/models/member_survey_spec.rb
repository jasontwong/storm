require 'rails_helper'

describe MemberSurvey do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member_survey)).to be_valid
  end
  it 'requires a code' do
    expect(FactoryGirl.build(:member_survey, code: nil)).not_to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:member_survey, company: nil)).not_to be_valid
  end
  it 'requires a member' do
    expect(FactoryGirl.build(:member_survey, member: nil)).not_to be_valid
  end
  it 'requires a order' do
    expect(FactoryGirl.build(:member_survey, order: nil)).not_to be_valid
  end
  it 'requires a store' do
    expect(FactoryGirl.build(:member_survey, store: nil)).not_to be_valid
  end
  it 'require completed to be false if not true' do
    expect(FactoryGirl.build(:member_survey, completed: 5).completed).to be_false
    expect(FactoryGirl.build(:member_survey, completed: 'a').completed).to be_false
    expect(FactoryGirl.build(:member_survey, completed: 1)).to be_valid
    expect(FactoryGirl.build(:member_survey, completed: 0)).to be_valid
  end
end
