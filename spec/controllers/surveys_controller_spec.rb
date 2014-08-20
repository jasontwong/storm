require 'rails_helper'

describe SurveysController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of surveys' do
      survey = FactoryGirl.create(:survey)
      get :index
      expect(assigns(:surveys)).to eq([survey])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested survey to @survey' do
      survey = FactoryGirl.create(:survey)
      get :show, id: survey
      expect(assigns(:survey)).to eq(survey)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:survey)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new survey' do
        expect{
          post :create, survey: FactoryGirl.attributes_for(:survey)
        }.to change(Survey, :count).by(1)
      end
      it 'returns created status' do
        post :create, survey: FactoryGirl.attributes_for(:survey)
        expect(response).to have_http_status(:created)
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new survey' do
        expect{
          post :create, survey: FactoryGirl.attributes_for(:invalid_survey)
        }.to_not change(Survey, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @survey = FactoryGirl.create(:survey)
    end

    context 'with valid attributes' do
      it 'locates requested survey' do
        put :update, id: @survey, survey: FactoryGirl.attributes_for(:survey)
        expect(assigns(:survey)).to eq(@survey)
      end
      it 'changes the survey attributes' do
        put :update, id: @survey, survey: FactoryGirl.attributes_for(:survey, title: 'foobar', description: 'foobaz')
        @survey.reload
        expect(@survey.title).to eq('foobar')
        expect(@survey.description).to eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'fails with validation error' do
        expect {
          put :update, id: @survey, survey: FactoryGirl.attributes_for(:invalid_survey, description: 'foobaz')
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @survey = FactoryGirl.create(:survey)
    end

    it 'deletes the survey' do
      expect{
        delete :destroy, id: @survey
      }.to change(Survey, :count).by(-1)
    end
  end

end
