require 'rails_helper'

describe Survey do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:survey)).to be_valid
  end
  it 'requires a title' do
    expect(FactoryGirl.build(:survey, title: nil)).not_to be_valid
  end
  it 'requires a company' do
    expect(FactoryGirl.build(:survey, company: nil)).not_to be_valid
  end
  it 'require default to be false if not true' do
    expect(FactoryGirl.build(:survey, default: 5).default).to be_falsey
    expect(FactoryGirl.build(:survey, default: 'a').default).to be_falsey
    expect(FactoryGirl.build(:survey, default: 1)).to be_valid
    expect(FactoryGirl.build(:survey, default: 0)).to be_valid
  end
end
