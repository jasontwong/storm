require 'rails_helper'

describe RewardsController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of rewards' do
      reward = FactoryGirl.create(:reward)
      get :index
      expect(assigns(:rewards)).to eq([reward])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
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
      expect(assigns(:rewards).length).to eq(5)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested reward to @reward' do
      reward = FactoryGirl.create(:reward)
      get :show, id: reward
      expect(assigns(:reward)).to eq(reward)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:reward)
      expect(response.status).to eq(200)
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
        expect(response.status).to eq(201)
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
        expect(assigns(:reward)).to eq(@reward)
      end
      it 'changes the reward attributes' do
        put :update, id: @reward, reward: FactoryGirl.attributes_for(:reward, title: 'foobar', description: 'foobaz')
        @reward.reload
        expect(@reward.title).to eq('foobar')
        expect(@reward.description).to eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'fails with validation error' do
        expect {
          put :update, id: @reward, reward: FactoryGirl.attributes_for(:invalid_reward, description: 'foobaz')
        }.to raise_error(ActiveRecord::RecordInvalid)
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
