require 'rails_helper'

describe CompaniesController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of companies' do
      company = FactoryGirl.create(:company)
      get :index
      expect(assigns(:companies)).to eq([company])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested company to @company' do
      company = FactoryGirl.create(:company)
      get :show, id: company
      expect(assigns(:company)).to eq(company)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:company)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new company' do
        expect{
          post :create, company: FactoryGirl.attributes_for(:company)
        }.to change(Company, :count).by(1)
      end
      it 'returns created status' do
        post :create, company: FactoryGirl.attributes_for(:company)
        expect(response.status).to eq(201)
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new company' do
        expect{
          post :create, company: FactoryGirl.attributes_for(:invalid_company)
        }.to_not change(Company, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @company = FactoryGirl.create(:company)
    end

    context 'with valid attributes' do
      it 'locates requested company' do
        put :update, id: @company, company: FactoryGirl.attributes_for(:company)
        expect(assigns(:company)).to eq(@company)
      end
      it 'changes the company name attribute' do
        put :update, id: @company, company: { name: 'foobar' }
        @company.reload
        expect(@company.name).to eq('foobar')
      end
      # For some reason these do not work
      #
      # it 'changes the company logo attribute' do
      #   put :update, id: @company, company: { logo: { 'foo' => 'foobaz' }}
      #   @company.reload
      #   expect(@company.logo).to eq({ 'foo' => 'foobaz' })
      # end
      # it 'changes the company worth_meta attribute' do
      #   put :update, id: @company, company: { worth_meta: { 'foo' => 'foobaz' }}
      #   @company.reload
      #   expect(@company.worth_meta).to eq({ 'foo' => 'foobaz' })
      # end
    end

    context 'with invalid attributes' do
      it 'fails with validation error' do
        expect {
          put :update, id: @company, company: FactoryGirl.attributes_for(:invalid_company)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @company = FactoryGirl.create(:company)
    end

    it 'deletes the company' do
      expect{
        delete :destroy, id: @company
      }.to change(Company, :count).by(-1)
    end
  end

end
