require 'spec_helper'

describe Survey do
  it 'has a valid factory' do
    FactoryGirl.build(:survey).should be_valid
  end
  it 'requires a title' do
    FactoryGirl.build(:survey, title: nil).should_not be_valid
  end
  it 'requires a company' do
    FactoryGirl.build(:survey, company: nil).should_not be_valid
  end
  it 'require default to be false if not true' do
    FactoryGirl.build(:survey, default: 5).default.should be_false
    FactoryGirl.build(:survey, default: 'a').default.should be_false
    FactoryGirl.build(:survey, default: 1).should be_valid
    FactoryGirl.build(:survey, default: 0).should be_valid
  end
end
