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
    context 'with extra attributes' do
      it 'creates a new member with extra attributes' do
        expect {
          post :create, member: FactoryGirl.attributes_for(:member), attrs: { foo: 'bar', hello: 'world' }
        }.to change(MemberAttribute, :count).by(2)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @member = FactoryGirl.create(:member)
    end

    context 'with valid attributes' do
      it 'locates requested member' do
        put :update, id: @member, member: FactoryGirl.attributes_for(:member)
        assigns(:member).should eq(@member)
      end
      it 'changes the member attributes' do
        put :update, id: @member, member: FactoryGirl.attributes_for(:member, fb_username: 'foobar', fb_password: 'foobaz')
        @member.reload
        @member.fb_username.should eq('foobar')
        @member.fb_password.should eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested member' do
        put :update, id: @member, member: FactoryGirl.attributes_for(:invalid_member)
        assigns(:member).should eq(@member)
      end
      it 'does not change member attributes' do
        put :update, id: @member, member: FactoryGirl.attributes_for(:invalid_member)
        @member.reload
        @member.fb_username.should eq(@member.fb_username)
        @member.fb_password.should_not eq('foobaz')
      end
    end

    context 'with extra attributes' do
      it 'updates a member with extra attributes' do
        put :update, id: @member, member: FactoryGirl.attributes_for(:member), attrs: { foo: 'bar' }
        assigns(:member).should eq(@member)
        @member.member_attributes[0].name.should eq('foo')
        @member.member_attributes[0].value.should eq('bar')
      end
    end

    context 'with survey answers' do
      it 'updates a member with answers to a survey' do
        answers = [
          FactoryGirl.attributes_for(:member_answer),
          FactoryGirl.attributes_for(:member_answer),
          FactoryGirl.attributes_for(:member_answer),
          FactoryGirl.attributes_for(:member_answer),
        ]
        expect{
          put :update, id: @member, member: FactoryGirl.attributes_for(:member), answers: answers
        }.to change(MemberAnswer, :count).by(4)
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @member = FactoryGirl.create(:member)
    end

    it 'makes the member inactive' do
      expect{
        delete :destroy, id: @member
      }.to change(Member, :count).by(0)
      @member.reload
      @member.active.should be_false
    end
  end

end
