require 'spec_helper'

describe Product do
  it 'has a valid factory' do
    FactoryGirl.build(:product).should be_valid
  end
  it 'requires an name' do
    FactoryGirl.build(:product, name: nil).should_not be_valid
  end
  it 'requires an price' do
    FactoryGirl.build(:product, price: nil).should_not be_valid
  end
  it 'requires price 2 be formatted properly' do
    price = FactoryGirl.build(:product).price
    price.should == price.round(2)
  end
  it 'requires an company' do
    FactoryGirl.build(:product, company: nil).should_not be_valid
  end
end
