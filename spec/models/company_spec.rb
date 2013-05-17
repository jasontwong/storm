require 'spec_helper'

describe Company do
  it 'has a valid factory' do
    FactoryGirl.build(:company).should be_valid
  end
  it 'requires a name' do
    FactoryGirl.build(:company, name: nil).should_not be_valid
  end
end
