require 'spec_helper'

describe Member do
  it 'has a valid factory' do
    FactoryGirl.build(:member).should be_valid
  end
end
