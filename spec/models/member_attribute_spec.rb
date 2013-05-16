require 'spec_helper'

describe MemberAttribute do
  it 'requires a member' do
    FactoryGirl.build(:member_attribute, member: nil).should_not be_valid
  end
  it 'requires a name' do
    FactoryGirl.build(:member_attribute, name: nil).should_not be_valid
  end
  it 'requires a unique member/name combination' do
    member = FactoryGirl.build(:member)
    attr1 = FactoryGirl.create(:member_attribute, name: 'hello', member: member)
    attr2 = FactoryGirl.build(:member_attribute, name: 'hello', member: member)
    attr2.should_not be_valid
  end
end
