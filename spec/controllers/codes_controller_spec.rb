require 'rails_helper'

describe CodesController, type: :controller do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of codes' do
      code = FactoryGirl.create(:code)
      get :index
      expect(assigns(:codes)).to eq([code])
    end
    it 'returns status ok' do
      get :index
      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    it 'assigns the requested code to @code' do
      code = FactoryGirl.create(:code)
      get :show, id: code
      expect(assigns(:code)).to eq(code)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:code)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new code' do
        expect{
          store = FactoryGirl.create(:store)
          code = FactoryGirl.attributes_for(:code)
          code[:store_id] = store[:id]
          post :create, code: code
        }.to change(Code, :count).by(1)
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new code' do
        expect{
          post :create, code: FactoryGirl.attributes_for(:invalid_code)
        }.to_not change(Code, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @code = FactoryGirl.create(:code)
    end

    context 'with valid attributes' do
      it 'locates requested code' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:code)
        expect(assigns(:code)).to eq(@code)
      end
      it 'changes the code attributes' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:code, qr: 'foobar', used: 5)
        @code.reload
        expect(@code.qr).to eq('foobar')
        expect(@code.used).to eq(5)
      end
    end

    context 'with invalid attributes' do
      it 'locates requested code' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:invalid_code)
        expect(assigns(:code)).to eq(@code)
      end
      it 'does not change code attributes' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:invalid_code, used: 5)
        @code.reload
        expect(@code.qr).to eq(@code.qr)
        expect(@code.used).not_to eq(5)
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @code = FactoryGirl.create(:code)
    end

    it 'changes the code so that active becomes false' do
      expect{
        delete :destroy, id: @code
      }.to change(Code, :count).by(0)
      @code.reload
      expect(@code.active).to be_falsey
    end
  end

end
