class StoresController < ApplicationController
  # GET /stores
  # GET /stores.json
  def index
    @stores = Store.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @stores.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
    @store = Store.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @store.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(params[:store])

    @store.surveys = Survey.where(id: params[:survey_ids]) if params[:survey_ids].present?

    if @store.save
      render json: @store, status: :created, location: @store
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    @store = Store.find(params[:id])

    @store.surveys = Survey.where(id: params[:survey_ids]) if params[:survey_ids].present?

    if @store.update_attributes(params[:store])
      head :no_content
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store = Store.find(params[:id])
    @store.destroy

    head :no_content
  end
end
