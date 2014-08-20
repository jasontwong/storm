require 'rails_helper'

describe Code do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:code)).to be_valid
  end
  it 'requires a qr' do
    expect(FactoryGirl.build(:code, qr: nil)).not_to be_valid
  end
  it 'requires used' do
    expect(FactoryGirl.build(:code, used: nil)).not_to be_valid
  end
  it 'requires active to be true or false' do
    expect(FactoryGirl.build(:code, active: 5)).active.to be_false
    expect(FactoryGirl.build(:code, active: 'a')).active.to be_false
    expect(FactoryGirl.build(:code, active: 1)).to be_valid
    expect(FactoryGirl.build(:code, active: 0)).to be_valid
  end
end
