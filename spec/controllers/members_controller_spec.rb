require 'spec_helper'

describe MembersController do
  describe 'GET #index' do
    it 'populates an array of members' do
      member = FactoryGirl.create(:member)
      get :index
      assigns(:members).should eq([member])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested member to @member' do
      member = FactoryGirl.create(:member)
      get :show, id: member
      assigns(:member).should eq(member)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:member)
      response.status.should == 200
    end
  end

  describe 'POST #create' do
    context 'with valid attribtues' do
      it 'creates a new member' do
        expect{
          post :create, member: FactoryGirl.attributes_for(:member)
        }.to change(Member, :count).by(1)
      end
      it 'returns created status' do
        post :create, member: FactoryGirl.attributes_for(:member)
        response.status.should == 201
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new member' do
        expect{
          post :create, member: FactoryGirl.attributes_for(:invalid_member)
        }.to_not change(Member, :count)
      end
    end
  end

  # have to figure out a way to test since this works with SQS
  describe 'PUT #update' do
    before :each do
      @member = FactoryGirl.create(:member)
    end

    context 'with valid attributes' do
      it 'locates requested member'
      it 'sends update info to SQS'
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @Member = FactoryGirl.create(:member)
    end

    it 'sends delete message to SQS'
  end
end
