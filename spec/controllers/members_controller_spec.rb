require 'spec_helper'
require 'bcrypt'

describe MembersController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

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

    context 'with points' do
      it 'can increase member points for a company' do
        num_points = 5
        points = FactoryGirl.create(:member_point, member: @member)
        put :update, id: @member, member: FactoryGirl.attributes_for(:member), points: num_points, company_id: points.company_id
        latest_points = MemberPoints.where(member_id: @member.id, company_id: points.company_id).last
        new_points = points.points + num_points
        new_points.should == latest_points.points
        new_points = points.total_points + num_points
        new_points.should == latest_points.total_points
      end
      it 'can decrease member points for a company without decreasing total points' do
        num_points = -5
        points = FactoryGirl.create(:member_point, member: @member)
        put :update, id: @member, member: FactoryGirl.attributes_for(:member), points: num_points, company_id: points.company_id
        latest_points = MemberPoints.where(member_id: @member.id, company_id: points.company_id).last
        new_points = points.points + num_points
        new_points.should == latest_points.points
        new_points = points.total_points
        new_points.should == latest_points.total_points
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

  # member verify section
  
  describe 'POST #verify' do
    before :each do
      @member = FactoryGirl.create(:member)
      @password = Digest::SHA256.new
      @password.update 'password'
      @member.password = BCrypt::Password.create(@password.hexdigest + @member.salt)
      @member.save
    end

    context 'valid password' do
      it 'returns member info' do
        post :verify, email: @member.email, password: @password
        assigns(:member).should eq(@member)
      end
    end

    context 'invalid password' do
      it 'returns an error' do
        post :verify, email: @member.email, password: 'wrong password'
        response.status.should == 422
      end
    end

    context 'invalid email' do
      it 'returns an error' do
        post :verify, email: 'foobar', password: @password
        response.status.should == 422
      end
    end
  end

  # member pass_reset section
  
  describe 'PUT #pass_reset' do
    before :each do
      @member = FactoryGirl.create(:member)
    end

    context 'valid email' do
      it 'returns member info' do
        put :pass_reset, email: @member.email
        @member.reload
        @member.temp_pass.should_not be_blank
        @member.temp_pass_expiration.should_not be_blank
      end
    end

    context 'invalid email' do
      it 'returns an error' do
        put :pass_reset, email: 'foobar'
        @member.reload
        @member.temp_pass.should be_blank
        @member.temp_pass_expiration.should be_blank
        response.status.should == 422
      end
    end
  end

  # member rewards section
  
  describe 'GET #reward_index' do
    it 'retrieves the rewards for a single member' do
      member = FactoryGirl.create(:member)
      reward = FactoryGirl.create(:member_reward, member: member)
      member.member_rewards << reward
      get :reward_index, id: member.id
      assigns(:member_rewards).should eq([reward])
    end
  end

  describe 'POST #reward_create' do
    before :each do
      @member_reward = FactoryGirl.attributes_for(:member_reward)
    end

    context 'with valid attributes' do
      it 'creates a new reward for a single member' do
        expect{
          reward = FactoryGirl.create(:reward)
          member = FactoryGirl.create(:member)
          @member_reward[:member_id] = member.id
          @member_reward[:reward_id] = reward.id
          post :reward_create, id: member.id, member_reward: @member_reward
        }.to change(MemberReward, :count).by(1)
      end
    end
  end

  describe 'PUT #reward_update' do
    before :each do
      @member_reward = FactoryGirl.create(:member_reward)
    end

    context 'with valid attributes' do
      it 'locates a reward for a single member' do
        put :reward_update, id: @member_reward.id, member_id: @member_reward.member.id, member_reward: FactoryGirl.attributes_for(:member_reward)
        assigns(:member_reward).should eq(@member_reward)
      end
      it 'changes reward attributes for a single member' do
        put :reward_update, id: @member_reward.id, member_id: @member_reward.member.id, member_reward: FactoryGirl.attributes_for(:member_reward, printed: 5, scanned: 55)
        @member_reward.reload
        @member_reward.printed.should == 5
        @member_reward.scanned.should == 55
      end
    end
  end

  # member points section
  
  describe 'GET #point_index' do
    before :each do
      @member = FactoryGirl.create(:member)
    end

    it 'retrieves the points for a single member' do
      point = FactoryGirl.create(:member_point, member: @member)
      @member.member_points << point
      get :point_index, id: @member.id
      assigns(:member_points).should eq([point])
    end
    it 'retrieves the points for a single member and company' do
      company = FactoryGirl.create(:company)
      point = FactoryGirl.create(:member_point, member: @member, company: company)
      @member.member_points << point
      get :point_index, id: @member.id, company_id: company.id
      assigns(:member_points).should eq(point)
    end
  end

end
