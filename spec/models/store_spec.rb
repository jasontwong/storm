require 'rails_helper'

describe Store do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:store)).to be_valid
  end
  it 'requires an name' do
    expect(FactoryGirl.build(:store, name: nil)).not_to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:store, company: nil)).not_to be_valid
  end
  it 'requires an address1' do
    expect(FactoryGirl.build(:store, address1: nil)).not_to be_valid
  end
  it 'requires an city' do
    expect(FactoryGirl.build(:store, city: nil)).not_to be_valid
  end
  it 'requires an state' do
    expect(FactoryGirl.build(:store, state: nil)).not_to be_valid
  end
  it 'requires an zip' do
    expect(FactoryGirl.build(:store, zip: nil)).not_to be_valid
  end
  it 'requires an country' do
    expect(FactoryGirl.build(:store, country: nil)).not_to be_valid
  end
  it 'requires an phone' do
    expect(FactoryGirl.build(:store, phone: nil)).not_to be_valid
  end
end
