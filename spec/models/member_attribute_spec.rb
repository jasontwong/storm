require 'rails_helper'

describe MemberAttribute do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member_attribute)).to be_valid
  end
end
