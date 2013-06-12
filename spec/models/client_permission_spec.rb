require 'spec_helper'

describe ClientPermission do
  it 'has a valid factory' do
    FactoryGirl.build(:client_permission).should be_valid
  end
  it 'requires a name' do
    FactoryGirl.build(:client_permission, name: nil).should_not be_valid
  end
  it 'requires name to be unique' do
    client_permission1 = FactoryGirl.create(:client_permission)
    client_permission2 = FactoryGirl.build(:client_permission, name: client_permission1.name)
    client_permission2.should_not be_valid
    client_permission2.should have(1).error_on(:name)
  end
end
