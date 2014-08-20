require 'rails_helper'

describe Company do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:company)).to be_valid
  end
  it 'requires a name' do
    expect(FactoryGirl.build(:company, name: nil)).not_to be_valid
  end
end
