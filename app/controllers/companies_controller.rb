class CompaniesController < ApplicationController
  # GET /companies
  # GET /companies.json
  def index
    @companies = Company.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @companies.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @company.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(params[:company])

    if @company.save
      log = Changelog.where(
        model: 'Company', 
        model_id: @company.id,
      ).first_or_create!
      log.model_action = 'create'
      log.save
      render json: @company, status: :created, location: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    @company = Company.find(params[:id])

    if @company.update_attributes(params[:company])
      log = Changelog.where(
        model: 'Company', 
        model_id: @company.id,
      ).first_or_create!
      log.model_action = 'update'
      log.save
      head :no_content
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    log = Changelog.where(
      model: 'Company', 
      model_id: @company.id,
    ).first_or_create!
    log.model_action = 'destroy'
    log.save

    head :no_content
  end
end
