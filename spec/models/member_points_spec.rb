require 'rails_helper'

describe MemberPoints do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member_point)).to be_valid
  end
  it 'requires a member' do
    expect(FactoryGirl.build(:member_point, member: nil)).not_to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:member_point, company: nil)).not_to be_valid
  end
end
