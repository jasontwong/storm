require 'rails_helper'

describe ClientsController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of clients' do
      client = FactoryGirl.create(:client)
      get :index
      expect(assigns(:clients)).to eq([client])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested client to @client' do
      client = FactoryGirl.create(:client)
      get :show, id: client
      expect(assigns(:client)).to eq(client)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:client)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new client' do
        expect{
          post :create, client: FactoryGirl.attributes_for(:client)
        }.to change(Client, :count).by(1)
      end
      it 'returns created status' do
        post :create, client: FactoryGirl.attributes_for(:client)
        expect(response.status).to eq(201)
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new client' do
        expect{
          post :create, client: FactoryGirl.attributes_for(:invalid_client)
        }.to_not change(Client, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @client = FactoryGirl.create(:client)
    end

    context 'with valid attributes' do
      it 'locates requested client' do
        put :update, id: @client, client: FactoryGirl.attributes_for(:client)
        expect(assigns(:client)).to eq(@client)
      end
      it 'changes the client attributes' do
        put :update, id: @client, client: FactoryGirl.attributes_for(:client, name: 'foobar', salt: 'foobaz')
        @client.reload
        expect(@client.name).to eq('foobar')
        expect(@client.salt).to eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'fails with validation error' do
        expect {
          put :update, id: @client, client: FactoryGirl.attributes_for(:invalid_client)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @client = FactoryGirl.create(:client)
    end

    it 'makes the client inactive' do
      expect{
        delete :destroy, id: @client
      }.to change(Member, :count).by(0)
      @client.reload
      expect(@client.active).to be_falsey
    end
  end

end
