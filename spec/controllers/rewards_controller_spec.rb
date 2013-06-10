require 'spec_helper'

describe RewardsController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of rewards' do
      reward = FactoryGirl.create(:reward)
      get :index
      assigns(:rewards).should eq([reward])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
    it 'populates an array of rewards for a specific company' do
      company_id = 37
      FactoryGirl.create(:reward, company_id: company_id)
      FactoryGirl.create(:reward, company_id: company_id)
      FactoryGirl.create(:reward, company_id: company_id)
      FactoryGirl.create(:reward, company_id: company_id)
      FactoryGirl.create(:reward, company_id: company_id)
      FactoryGirl.create(:reward)
      FactoryGirl.create(:reward)
      get :index, company_id: company_id
      assigns(:rewards).length.should == 5
    end
  end

  describe 'GET #show' do
    it 'assigns the requested reward to @reward' do
      reward = FactoryGirl.create(:reward)
      get :show, id: reward
      assigns(:reward).should eq(reward)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:reward)
      response.status.should == 200
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new reward' do
        expect{
          post :create, reward: FactoryGirl.attributes_for(:reward)
        }.to change(Reward, :count).by(1)
      end
      it 'returns created status' do
        post :create, reward: FactoryGirl.attributes_for(:reward)
        response.status.should == 201
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new reward' do
        expect{
          post :create, reward: FactoryGirl.attributes_for(:invalid_reward)
        }.to_not change(Reward, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @reward = FactoryGirl.create(:reward)
    end

    context 'with valid attributes' do
      it 'locates requested reward' do
        put :update, id: @reward, reward: FactoryGirl.attributes_for(:reward)
        assigns(:reward).should eq(@reward)
      end
      it 'changes the reward attributes' do
        put :update, id: @reward, reward: FactoryGirl.attributes_for(:reward, title: 'foobar', description: 'foobaz')
        @reward.reload
        @reward.title.should eq('foobar')
        @reward.description.should eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested reward' do
        put :update, id: @reward, reward: FactoryGirl.attributes_for(:invalid_reward)
        assigns(:reward).should eq(@reward)
      end
      it 'does not change reward attributes' do
        put :update, id: @reward, reward: FactoryGirl.attributes_for(:invalid_reward, description: 'foobaz')
        @reward.reload
        @reward.title.should eq(@reward.title)
        @reward.description.should_not eq('foobaz')
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @reward = FactoryGirl.create(:reward)
    end

    it 'deletes the reward' do
      expect{
        delete :destroy, id: @reward
      }.to change(Reward, :count).by(-1)
    end
  end

end
