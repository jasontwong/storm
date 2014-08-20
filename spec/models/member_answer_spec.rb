require 'rails_helper'

describe MemberAnswer do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member_answer)).to be_valid
  end
  it 'requires a member' do
    expect(FactoryGirl.build(:member_answer, member: nil)).not_to be_valid
  end
  it 'requires a code' do
    expect(FactoryGirl.build(:member_answer, code: nil)).not_to be_valid
  end
  it 'requires a question' do
    expect(FactoryGirl.build(:member_answer, question: nil)).not_to be_valid
  end
end
