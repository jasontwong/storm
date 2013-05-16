require 'spec_helper'

describe MemberAttribute do
  it 'has a valid factory' do
    FactoryGirl.build(:member_attribute).should be_valid
  end
end
