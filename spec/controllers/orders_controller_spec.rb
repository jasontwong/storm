require 'spec_helper'

describe OrdersController do

  describe 'GET #index' do
    it 'populates an array of orders' do
      order = FactoryGirl.create(:order)
      get :index
      assigns(:orders).should eq([order])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested order to @order' do
      order = FactoryGirl.create(:order)
      get :show, id: order
      assigns(:order).should eq(order)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:order)
      response.status.should == 200
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new order' do
        expect{
          post :create, order: FactoryGirl.attributes_for(:order)
        }.to change(Order, :count).by(1)
      end
      it 'returns created status' do
        post :create, order: FactoryGirl.attributes_for(:order)
        response.status.should == 201
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new order' do
        expect{
          post :create, order: FactoryGirl.attributes_for(:invalid_order)
        }.to_not change(Order, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @order = FactoryGirl.create(:order)
    end

    context 'with valid attributes' do
      it 'locates requested order' do
        put :update, id: @order, order: FactoryGirl.attributes_for(:order)
        assigns(:order).should eq(@order)
      end
      it 'changes the order attributes' do
        put :update, id: @order, order: FactoryGirl.attributes_for(:order, checkin_worth: 0.56, server: 'foobaz')
        @order.reload
        @order.checkin_worth.should == 0.56
        @order.server.should eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested order' do
        put :update, id: @order, order: FactoryGirl.attributes_for(:invalid_order)
        assigns(:order).should eq(@order)
      end
      it 'does not change order attributes' do
        put :update, id: @order, order: FactoryGirl.attributes_for(:invalid_order, server: 'foobaz')
        @order.reload
        @order.checkin_worth.should eq(@order.checkin_worth)
        @order.server.should_not eq('foobaz')
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @order = FactoryGirl.create(:order)
    end

    it 'deletes the order' do
      expect{
        delete :destroy, id: @order
      }.to change(Order, :count).by(-1)
    end
  end

end
