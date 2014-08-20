require 'rails_helper'

describe SurveyQuestionsController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of survey_questions' do
      survey_question = FactoryGirl.create(:survey_question)
      get :index
      assigns(:survey_questions).to eq([survey_question])
    end
    it 'returns status ok' do
      get :index
      response.status.to == 200
    end
    it 'populates an array of survey_questions based on the qr code' do
      order = FactoryGirl.create(:order)
      questions = [
        FactoryGirl.create(:survey_question),
        FactoryGirl.create(:survey_question),
        FactoryGirl.create(:survey_question),
        FactoryGirl.create(:survey_question),
      ]
      FactoryGirl.create(:survey_question)
      survey = FactoryGirl.create(:survey, store: order.store, survey_questions: questions)
      get :index, qr: order.code.qr
      assigns(:survey_questions).length.to == 4
    end
  end

  describe 'GET #show' do
    it 'assigns the requested survey_question to @survey_question' do
      survey_question = FactoryGirl.create(:survey_question)
      get :show, id: survey_question
      assigns(:survey_question).to eq(survey_question)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:survey_question)
      response.status.to == 200
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new survey_question' do
        expect{
          post :create, survey_question: FactoryGirl.attributes_for(:survey_question)
        }.to change(SurveyQuestion, :count).by(1)
      end
      it 'returns created status' do
        post :create, survey_question: FactoryGirl.attributes_for(:survey_question)
        response.status.to == 201
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new survey_question' do
        expect{
          post :create, survey_question: FactoryGirl.attributes_for(:invalid_survey_question)
        }.to_not change(SurveyQuestion, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @survey_question = FactoryGirl.create(:survey_question)
    end

    context 'with valid attributes' do
      it 'locates requested survey_question' do
        put :update, id: @survey_question, survey_question: FactoryGirl.attributes_for(:survey_question)
        assigns(:survey_question).to eq(@survey_question)
      end
      it 'changes the survey_question attributes' do
        put :update, id: @survey_question, survey_question: FactoryGirl.attributes_for(:survey_question, question: 'foobar', answer_type: 'foobaz')
        @survey_question.reload
        @survey_question.question.to eq('foobar')
        @survey_question.answer_type.to eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested survey_question' do
        put :update, id: @survey_question, survey_question: FactoryGirl.attributes_for(:invalid_survey_question)
        assigns(:survey_question).to eq(@survey_question)
      end
      it 'does not change survey_question attributes' do
        put :update, id: @survey_question, survey_question: FactoryGirl.attributes_for(:invalid_survey_question, answer_type: 'foobaz')
        @survey_question.reload
        @survey_question.question.to eq(@survey_question.question)
        @survey_question.answer_type.not_to eq('foobaz')
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @survey_question = FactoryGirl.create(:survey_question)
    end

    it 'makes the survey_question inactive' do
      expect{
        delete :destroy, id: @survey_question
      }.to change(SurveyQuestion, :count).by(0)
      @survey_question.reload
      @survey_question.active.to be_false
    end
  end

end
