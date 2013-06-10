require 'spec_helper'

describe CompaniesController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of companies' do
      company = FactoryGirl.create(:company)
      get :index
      assigns(:companies).should eq([company])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested company to @company' do
      company = FactoryGirl.create(:company)
      get :show, id: company
      assigns(:company).should eq(company)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:company)
      response.status.should == 200
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
        response.status.should == 201
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
        assigns(:company).should eq(@company)
      end
      it 'changes the company attributes' do
        put :update, id: @company, company: FactoryGirl.attributes_for(:company, name: 'foobar', logo: 'foobaz')
        @company.reload
        @company.name.should eq('foobar')
        @company.logo.should eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested company' do
        put :update, id: @company, company: FactoryGirl.attributes_for(:invalid_company)
        assigns(:company).should eq(@company)
      end
      it 'does not change company attributes' do
        put :update, id: @company, company: FactoryGirl.attributes_for(:invalid_company)
        @company.reload
        @company.name.should eq(@company.name)
        @company.logo.should_not eq('foobaz')
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
