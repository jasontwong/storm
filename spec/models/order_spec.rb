require 'spec_helper'

describe Order do
  it 'has a valid factory' do
    FactoryGirl.build(:order).should be_valid
  end
  it 'requires a store' do
    FactoryGirl.build(:order, store: nil).should_not be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:order, company: nil).should_not be_valid
  end
  it 'requires a code' do
    FactoryGirl.build(:order, code: nil).should_not be_valid
  end
  it 'requires an amount' do
    FactoryGirl.build(:order, amount: nil).should_not be_valid
  end
  it 'requires an survey_worth' do
    FactoryGirl.build(:order, survey_worth: nil).should_not be_valid
  end
end
