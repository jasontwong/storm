require 'rails_helper'

describe Member do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:member)).to be_valid
  end
  it 'requires an email' do
    expect(FactoryGirl.build(:member, email: nil)).to be_valid
  end
  it 'requires email to be unique' do
    member1 = FactoryGirl.create(:member)
    member2 = FactoryGirl.build(:member, email: member1.email)
    expect(member2).not_to be_valid
    expect(member2).to have(1).error_on(:email)
  end
  it 'requires proper email format' do
    expect(FactoryGirl.build(:member, email: 'kdjfkjdf')).not_to be_valid
  end
  it 'require active to be false if not true' do
    expect(FactoryGirl.build(:member, active: 5)).active.to be_false
    expect(FactoryGirl.build(:member, active: 'a')).active.to be_false
    expect(FactoryGirl.build(:member, active: 1)).to be_valid
    expect(FactoryGirl.build(:member, active: 0)).to be_valid
  end
end
