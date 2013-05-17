require 'spec_helper'

describe Store do
  it 'has a valid factory' do
    FactoryGirl.build(:store).should be_valid
  end
  it 'requires an name' do
    FactoryGirl.build(:store, name: nil).should_not be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:store, company: nil).should_not be_valid
  end
  it 'requires an address1' do
    FactoryGirl.build(:store, address1: nil).should_not be_valid
  end
  it 'requires an city' do
    FactoryGirl.build(:store, city: nil).should_not be_valid
  end
  it 'requires an state' do
    FactoryGirl.build(:store, state: nil).should_not be_valid
  end
  it 'requires an zip' do
    FactoryGirl.build(:store, zip: nil).should_not be_valid
  end
  it 'requires an country' do
    FactoryGirl.build(:store, country: nil).should_not be_valid
  end
  it 'requires an phone' do
    FactoryGirl.build(:store, phone: nil).should_not be_valid
  end
end
