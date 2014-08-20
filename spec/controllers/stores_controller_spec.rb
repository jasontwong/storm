require 'rails_helper'

describe StoresController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of stores' do
      store = FactoryGirl.create(:store)
      get :index
      expect(assigns(:stores)).to eq([store])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested store to @store' do
      store = FactoryGirl.create(:store)
      get :show, id: store
      expect(assigns(:store)).to eq(store)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:store)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new store' do
        expect{
          post :create, store: FactoryGirl.attributes_for(:store)
        }.to change(Store, :count).by(1)
      end
      it 'returns created status' do
        post :create, store: FactoryGirl.attributes_for(:store)
        expect(response).to have_http_status(:created)
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new store' do
        expect{
          post :create, store: FactoryGirl.attributes_for(:invalid_store)
        }.to_not change(Store, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @store = FactoryGirl.create(:store)
    end

    context 'with valid attributes' do
      it 'locates requested store' do
        put :update, id: @store, store: FactoryGirl.attributes_for(:store)
        expect(assigns(:store)).to eq(@store)
      end
      it 'changes the store attributes' do
        put :update, id: @store, store: FactoryGirl.attributes_for(:store, name: 'foobar', city: 'foobaz')
        @store.reload
        expect(@store.name).to eq('foobar')
        expect(@store.city).to eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'fails with validation error' do
        expect {
          put :update, id: @store, store: FactoryGirl.attributes_for(:invalid_store, city: 'foobaz')
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @store = FactoryGirl.create(:store)
    end

    it 'deletes the store' do
      expect{
        delete :destroy, id: @store
      }.to change(Store, :count).by(-1)
    end
  end

end
