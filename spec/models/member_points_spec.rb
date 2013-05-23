require 'spec_helper'

describe MemberPoints do
  it 'has a valid factory' do
    FactoryGirl.build(:member_point).should be_valid
  end
  it 'requires a member' do
    FactoryGirl.build(:member_point, member: nil).should_not be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:member_point, company: nil).should_not be_valid
  end
end
