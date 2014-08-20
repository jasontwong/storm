require 'rails_helper'

RSpec.describe SurveyQuestionCategoriesController, :type => :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

end
