require 'spec_helper'

describe MembersController do
  describe 'GET #index' do
    it 'populates an array of members' do
      member = FactoryGirl.create(:member)
      get :index
      assigns(:members).should eq([member])
    end
    it 'returns json encoded version' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested member to @member'
    it 'returns json encoded version'
  end

  describe 'POST #create' do
    context 'with valid attribtues' do
      it 'creates a new user in the database'
      it 'returns json encoded version'
    end
  end
  it 'sends an update command'
  it 'sends a delete command'
end
