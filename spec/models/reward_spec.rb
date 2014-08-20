require 'rails_helper'

describe Reward do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:reward)).to be_valid
  end
  it 'requires a title' do
    expect(FactoryGirl.build(:reward, title: nil)).not_to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:reward, company: nil)).not_to be_valid
  end
  it 'requires a cost' do
    expect(FactoryGirl.build(:reward, cost: nil)).not_to be_valid
  end
  it 'requires an uses_left' do
    expect(FactoryGirl.build(:reward, uses_left: nil)).not_to be_valid
  end
end
