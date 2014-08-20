require 'rails_helper'

describe MemberAnswer do
  it 'has a valid factory' do
    FactoryGirl.build(:member_answer).should be_valid
  end
  it 'requires a member' do
    FactoryGirl.build(:member_answer, member: nil).should_not be_valid
  end
  it 'requires a code' do
    FactoryGirl.build(:member_answer, code: nil).should_not be_valid
  end
  it 'requires a question' do
    FactoryGirl.build(:member_answer, question: nil).should_not be_valid
  end
end
