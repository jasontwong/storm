require 'spec_helper'

describe ProductsController do
  before :each do
    @token = FactoryGirl.create(:api_key)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(@token.access_token)
  end

  describe 'GET #index' do
    it 'populates an array of products' do
      product = FactoryGirl.create(:product)
      get :index
      assigns(:products).should eq([product])
    end
    it 'returns status ok' do
      get :index
      response.status.should == 200
    end
  end

  describe 'GET #show' do
    it 'assigns the requested product to @product' do
      product = FactoryGirl.create(:product)
      get :show, id: product
      assigns(:product).should eq(product)
    end
    it 'returns status ok' do
      get :show, id: FactoryGirl.create(:product)
      response.status.should == 200
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'creates a new product' do
        expect{
          post :create, product: FactoryGirl.attributes_for(:product)
        }.to change(Product, :count).by(1)
      end
      it 'returns created status' do
        post :create, product: FactoryGirl.attributes_for(:product)
        response.status.should == 201
      end
    end
    context 'with invalid attributes' do
      it 'does not create a new product' do
        expect{
          post :create, product: FactoryGirl.attributes_for(:invalid_product)
        }.to_not change(Product, :count)
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @product = FactoryGirl.create(:product)
    end

    context 'with valid attributes' do
      it 'locates requested product' do
        put :update, id: @product, product: FactoryGirl.attributes_for(:product)
        assigns(:product).should eq(@product)
      end
      it 'changes the product attributes' do
        put :update, id: @product, product: FactoryGirl.attributes_for(:product, name: 'foobar', size: 'foobaz')
        @product.reload
        @product.name.should eq('foobar')
        @product.size.should eq('foobaz')
      end
    end

    context 'with invalid attributes' do
      it 'locates requested product' do
        put :update, id: @product, product: FactoryGirl.attributes_for(:invalid_product)
        assigns(:product).should eq(@product)
      end
      it 'does not change product attributes' do
        put :update, id: @product, product: FactoryGirl.attributes_for(:invalid_product, size: 'foobaz')
        @product.reload
        @product.name.should eq(@product.name)
        @product.size.should_not eq('foobaz')
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @product = FactoryGirl.create(:product)
    end

    it 'deletes the product' do
      expect{
        delete :destroy, id: @product
      }.to change(Product, :count).by(-1)
    end
  end

end
