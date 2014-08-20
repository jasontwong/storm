require 'rails_helper'

describe CodesController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of codes' do
      code = FactoryGirl.create(:code)
      get :index
      assigns(:codes).should eq([code])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested code to @code' do
      code = FactoryGirl.create(:code)
      get :show, id: code
      assigns(:code).should eq(code)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:code)
      response.status.should == 200
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
        assigns(:code).should eq(@code)
      end
      it 'changes the code attributes' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:code, qr: 'foobar', used: 5)
        @code.reload
        @code.qr.should eq('foobar')
        @code.used.should == 5
      end
    end

    context 'with invalid attributes' do
      it 'locates requested code' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:invalid_code)
        assigns(:code).should eq(@code)
      end
      it 'does not change code attributes' do
        put :update, id: @code, code: FactoryGirl.attributes_for(:invalid_code, used: 5)
        @code.reload
        @code.qr.should eq(@code.qr)
        @code.used.should_not == 5
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
      @code.active.should be_false
    end
  end

  # TODO Take this functionality out of the API and into worker thread
  describe 'parse receipts' do
    it 'parses a receipt with 3 columns' do
      receipt = Receipt.new(File.read(Rails.root.join('extras/receipts/3col.txt')))
      order = receipt.parse_data(3)
      order[:items].length.should == 2
    end
  end

  describe 'POST #scan' do
    before :each do
      company = FactoryGirl.create(:company)
      survey = FactoryGirl.create(:survey, company: company)
      survey_question = FactoryGirl.create(:survey_question, company: company)
      store = FactoryGirl.create(:store, company: company)
      @code = FactoryGirl.create(:code, store: store)
      @member = FactoryGirl.create(:member)
      order = FactoryGirl.create(:order, code_id: @code.id)
    end
    context 'with valid attributes' do
      it 'locates requested code' do
        post :scan, qr: @code.qr, member_id: @member.id
        assigns(:code).should eq(@code)
        used = @code.used
        @code.reload
        @code.active.should be_false
        @code.used.should == used + 1
      end
    end
  end

end
