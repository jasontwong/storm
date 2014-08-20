require 'rails_helper'

RSpec.describe MemberRewardsController, :type => :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of member rewards based on a member' do
      member = FactoryGirl.create(:member)
      member_reward = FactoryGirl.create(:member_reward, member: member)
      get :index, member_id: member
      expect(assigns(:member_rewards)).to eq([member_reward])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
    end
  end

end
