class CompaniesController < ApplicationController
  # {{{ def index
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

    if params[:page]
      @companies = @companies.page(params[:page])
      if params[:per_page]
        @companies = @companies.per(params[:per_page])
      end
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

  # }}}
  # {{{ def show
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

  # }}}
  # {{{ def create
  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    if @company.save
      render json: @company, status: :created, location: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def update
  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    @company = Company.find(params[:id])

    if @company.update_attributes!(company_params)
      head :no_content
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def destroy
  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    head :no_content
  end
  
  # }}}
  # {{{ def beacon_verify
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

  # }}}
  # {{{ def create_payload
  # GET /companies/create_payload
  # GET /companies/create_payload.json
  def create_payload
    AWS.config(
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )
    
    bucket_name = ENV['AWS_STORM_BUCKET']
    file_name = 'active-companies.json'
          
    # Get an instance of the S3 interface.
    s3 = AWS::S3.new

    # Upload a file.
    key = File.basename(file_name)
    s3.buckets[bucket_name].objects[key].write(Company.where(active: true).to_json(include: [:rewards, :stores]))
  end
  #
  # }}}
  private
    # {{{ def company_params
    def company_params
      params.require(:company).permit(:name, :description, :phone, :survey_question_limit, :location, :logo, :active)
    end

    # }}}
end
