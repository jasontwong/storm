require 'rails_helper'

describe Reward do
  it 'has a valid factory' do
    FactoryGirl.build(:reward).should be_valid
  end
  it 'requires a title' do
    FactoryGirl.build(:reward, title: nil).should_not be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:reward, company: nil).should_not be_valid
  end
  it 'requires a cost' do
    FactoryGirl.build(:reward, cost: nil).should_not be_valid
  end
  it 'requires an uses_left' do
    FactoryGirl.build(:reward, uses_left: nil).should_not be_valid
  end
end
