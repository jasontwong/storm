class OrderDetailsController < ApplicationController
  # GET /order_details
  # GET /order_details.json
  def index
    @order_details = OrderDetail.order('created_at ASC')

    if params[:name]
      @order_details = @order_details.where(name: params[:name])
    end

    if params[:no_product_id]
      @order_details = @order_details.where(product_id: nil)
    end

    render json: @order_details
  end

  # GET /order_details/1
  # GET /order_details/1.json
  def show
    @order_detail = OrderDetail.find(params[:id])

    render json: @order_detail
  end

  # POST /order_details
  # POST /order_details.json
  def create
    @order_detail = OrderDetail.new(params[:order_detail])

    if @order_detail.save
      render json: @order_detail, status: :created, location: @order_detail
    else
      render json: @order_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /order_details/1
  # PATCH/PUT /order_details/1.json
  def update
    @order_detail = OrderDetail.find(params[:id])

    if @order_detail.update_attributes(params[:order_detail])
      head :no_content
    else
      render json: @order_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /order_details/1
  # DELETE /order_details/1.json
  def destroy
    @order_detail = OrderDetail.find(params[:id])
    @order_detail.destroy

    head :no_content
  end
end
