class StoresController < ApplicationController
  # {{{ def index
  # GET /stores
  # GET /stores.json
  def index
    @stores = Store.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @stores.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # }}}
  # {{{ def show
  # GET /stores/1
  # GET /stores/1.json
  def show
    @store = Store.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @store.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # }}}
  # {{{ def create
  # POST /stores
  # POST /stores.json
  def create
    @store = Store.new(store_params)

    @store.surveys = Survey.where(id: params[:survey_ids]) if params[:survey_ids].present?

    if @store.save
      render json: @store, status: :created, location: @store
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def update
  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    @store = Store.find(params[:id])

    @store.surveys = Survey.where(id: params[:survey_ids]) if params[:survey_ids].present?

    if @store.update_attributes!(store_params)
      head :no_content
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def destroy
  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    @store = Store.find(params[:id])
    @store.destroy

    head :no_content
  end
  
  # }}}
  private
    # {{{ def store_params
    def store_params
      params.require(:store).permit(:company_id, :name, :phone, :address1, :address2, :city, :state, :country, :zip, :store_group_id)
    end

    # }}}
end
