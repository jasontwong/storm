require 'rails_helper'

describe Member do
  it 'has a valid factory' do
    FactoryGirl.build(:member).should be_valid
  end
  it 'requires an email' do
    FactoryGirl.build(:member, email: nil).should be_valid
  end
  it 'requires email to be unique' do
    member1 = FactoryGirl.create(:member)
    member2 = FactoryGirl.build(:member, email: member1.email)
    member2.should_not be_valid
    member2.should have(1).error_on(:email)
  end
  it 'requires proper email format' do
    FactoryGirl.build(:member, email: 'kdjfkjdf').should_not be_valid
  end
  it 'require active to be false if not true' do
    FactoryGirl.build(:member, active: 5).active.should be_false
    FactoryGirl.build(:member, active: 'a').active.should be_false
    FactoryGirl.build(:member, active: 1).should be_valid
    FactoryGirl.build(:member, active: 0).should be_valid
  end
end
