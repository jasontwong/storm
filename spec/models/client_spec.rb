require 'rails_helper'

describe Client do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:client)).to be_valid
  end
  it 'requires an email' do
    expect(FactoryGirl.build(:client, email: nil)).not_to be_valid
  end
  it 'requires email to be unique' do
    client1 = FactoryGirl.create(:client)
    client2 = FactoryGirl.build(:client, email: client1.email)
    expect(client2).not_to be_valid
    expect(client2).to have(1).error_on(:email)
  end
  it 'requires proper email format' do
    expect(FactoryGirl.build(:client, email: 'kdjfkjdf')).not_to be_valid
  end
  it 'require active to be false if not true' do
    expect(FactoryGirl.build(:client, active: 5).active).to be_falsey
    expect(FactoryGirl.build(:client, active: 'a').active).to be_falsey
    expect(FactoryGirl.build(:client, active: 1)).to be_valid
    expect(FactoryGirl.build(:client, active: 0)).to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:client, company: nil)).not_to be_valid
  end
  it 'requires a password' do
    expect(FactoryGirl.build(:client, password: nil)).not_to be_valid
  end
  it 'requires a salt' do
    expect(FactoryGirl.build(:client, salt: nil)).not_to be_valid
  end
end
