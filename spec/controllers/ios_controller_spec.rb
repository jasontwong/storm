require 'rails_helper'

describe IosController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'POST #check_version' do
    it 'verifies ios version support is not valid' do
      post :check_version, version: 1.0
      expect(JSON.parse(response.body, symbolize_names: true)).to eq({success: false})
    end
    it 'verifies ios version support is valid' do
      post :check_version, version: 100.0
      expect(JSON.parse(response.body, symbolize_names: true)).to eq({success: true})
    end
  end

end
