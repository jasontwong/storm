require 'spec_helper'

describe ClientGroup do
  it 'has a valid factory' do
    FactoryGirl.build(:client_group).should be_valid
  end
  it 'requires a name' do
    FactoryGirl.build(:client_group, name: nil).should_not be_valid
  end
  it 'requires name to be unique' do
    client_group1 = FactoryGirl.create(:client_group)
    client_group2 = FactoryGirl.build(:client_group, name: client_group1.name)
    client_group2.should_not be_valid
    client_group2.should have(1).error_on(:name)
  end
end
