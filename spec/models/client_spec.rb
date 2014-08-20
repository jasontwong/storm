require 'rails_helper'

describe Client do
  it 'has a valid factory' do
    FactoryGirl.build(:client).should be_valid
  end
  it 'requires an email' do
    FactoryGirl.build(:client, email: nil).should_not be_valid
  end
  it 'requires email to be unique' do
    client1 = FactoryGirl.create(:client)
    client2 = FactoryGirl.build(:client, email: client1.email)
    client2.should_not be_valid
    client2.should have(1).error_on(:email)
  end
  it 'requires proper email format' do
    FactoryGirl.build(:client, email: 'kdjfkjdf').should_not be_valid
  end
  it 'require active to be false if not true' do
    FactoryGirl.build(:client, active: 5).active.should be_false
    FactoryGirl.build(:client, active: 'a').active.should be_false
    FactoryGirl.build(:client, active: 1).should be_valid
    FactoryGirl.build(:client, active: 0).should be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:client, company: nil).should_not be_valid
  end
  it 'requires a password' do
    FactoryGirl.build(:client, password: nil).should_not be_valid
  end
  it 'requires a salt' do
    FactoryGirl.build(:client, salt: nil).should_not be_valid
  end
end
