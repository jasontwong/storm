class CompaniesController < ApplicationController
  # GET /companies
  # GET /companies.json
  def index
    if params[:give_all]
      @companies = Company.all
    else
      active = true
      active = false if params[:inactive]
      @companies = Company.where(active: active)
    end

    params[:include] = [] unless params[:include].is_a? Array

    if params[:include].include?('stores') && params[:include].include?('rewards') && active
      render json: @companies.to_json(
        except: [ :created_at, :updated_at, :html, :description, :worth_meta, :worth_type ],
        include: {
          stores: {
            except: [ :receipt_type, :full_address, :created_at, :updated_at ]
          },
          rewards: {
            except: [ :images, :description, :uses_left, :created_at, :updated_at ]
          }
        }
      )
    else
      render json: @companies.to_json(:include => params[:include].collect { |data| data.to_sym })
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    active = true
    active = false if params[:inactive]
    @company = Company.find(params[:id])

    if active && !@company.active
      raise ActiveRecord::RecordNotFound
    end

    params[:include] = [] unless params[:include].is_a? Array
    params[:include] << "rewards"

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
    @company.active = false
    @comapny.save

    log = Changelog.where(
      model: 'Company', 
      model_id: @company.id,
    ).first_or_create!
    log.model_action = 'destroy'
    log.save

    log = Changelog.where(
      model: 'Company', 
      model_id: @company.id,
    ).first_or_create!
    log.model_action = 'destroy'
    log.save

    head :no_content
  end
  
  # POST /companies/1/beacon_verify
  # POST /companies/1/beacon_verify.json
  def beacon_verify
    major = params[:major].to_i
    minor = params[:minor].to_i
    @company = Company.find(params[:id])
    stores = @company.stores
    found = false

    stores.each do |store|
      codes = store.codes
      codes.each do |code|
        if code.major == major && code.minor == minor
          found = true
          break
        end
      end
      break if found
    end

    if found
      render json: @company
    else
      render json: { company: "Not found" }, status: :unprocessable_entity
    end
  end

end
