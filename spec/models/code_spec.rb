require 'rails_helper'

describe Code do
  it 'has a valid factory' do
    FactoryGirl.build(:code).should be_valid
  end
  it 'requires a qr' do
    FactoryGirl.build(:code, qr: nil).should_not be_valid
  end
  it 'requires used' do
    FactoryGirl.build(:code, used: nil).should_not be_valid
  end
  it 'requires active to be true or false' do
    FactoryGirl.build(:code, active: 5).active.should be_false
    FactoryGirl.build(:code, active: 'a').active.should be_false
    FactoryGirl.build(:code, active: 1).should be_valid
    FactoryGirl.build(:code, active: 0).should be_valid
  end
end
