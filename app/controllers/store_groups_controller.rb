class StoreGroupsController < ApplicationController
  # GET /store_groups
  # GET /store_groups.json
  def index
    @store_groups = StoreGroup.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @store_groups.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /store_groups/1
  # GET /store_groups/1.json
  def show
    @store_group = StoreGroup.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @store_group.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /store_groups
  # POST /store_groups.json
  def create
    @store_group = StoreGroup.new(params[:store_group])

    if @store_group.save
      render json: @store_group, status: :created, location: @store_group
    else
      render json: @store_group.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /store_groups/1
  # PATCH/PUT /store_groups/1.json
  def update
    @store_group = StoreGroup.find(params[:id])

    if @store_group.update(params[:store_group])
      head :no_content
    else
      render json: @store_group.errors, status: :unprocessable_entity
    end
  end

  # DELETE /store_groups/1
  # DELETE /store_groups/1.json
  def destroy
    @store_group = StoreGroup.find(params[:id])
    @store_group.destroy

    head :no_content
  end
end
