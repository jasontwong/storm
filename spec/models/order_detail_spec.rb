require 'spec_helper'

describe OrderDetail do
  it 'has a valid factory' do
    FactoryGirl.build(:order_detail).should be_valid
  end
  it 'requires an order' do
    FactoryGirl.build(:order_detail, order: nil).should_not be_valid
  end
  it 'requires a name' do
    FactoryGirl.build(:order_detail, name: nil).should_not be_valid
  end
  it 'requires a code' do
    FactoryGirl.build(:order_detail, code: nil).should_not be_valid
  end
  it 'requires an quantity' do
    FactoryGirl.build(:order_detail, quantity: nil).should_not be_valid
  end
  it 'requires an price' do
    FactoryGirl.build(:order_detail, price: nil).should_not be_valid
  end
end
