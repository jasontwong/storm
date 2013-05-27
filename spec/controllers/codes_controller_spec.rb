require 'spec_helper'

describe CodesController do

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
          post :create, code: FactoryGirl.attributes_for(:code)
        }.to change(Code, :count).by(1)
      end
      it 'returns created status' do
        post :create, code: FactoryGirl.attributes_for(:code)
        response.status.should == 201
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

end
