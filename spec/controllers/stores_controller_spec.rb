require 'rails_helper'

describe StoresController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of stores' do
      store = FactoryGirl.create(:store)
      get :index
      assigns(:stores).should eq([store])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested store to @store' do
      store = FactoryGirl.create(:store)
      get :show, id: store
      assigns(:store).should eq(store)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:store)
      response.status.should == 200
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
        response.status.should == 201
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
        assigns(:store).should eq(@store)
      end
      it 'changes the store attributes' do
        put :update, id: @store, store: FactoryGirl.attributes_for(:store, name: 'foobar', city: 'foobaz')
        @store.reload
        @store.name.should eq('foobar')
        @store.city.should eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested store' do
        put :update, id: @store, store: FactoryGirl.attributes_for(:invalid_store)
        assigns(:store).should eq(@store)
      end
      it 'does not change store attributes' do
        put :update, id: @store, store: FactoryGirl.attributes_for(:invalid_store, city: 'foobaz')
        @store.reload
        @store.name.should eq(@store.name)
        @store.city.should_not eq('foobaz')
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
