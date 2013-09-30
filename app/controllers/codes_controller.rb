class CodesController < ApplicationController
  # GET /codes
  # GET /codes.json
  def index
    @codes = Code.all

    render json: @codes
  end

  # GET /codes/1
  # GET /codes/1.json
  def show
    @code = Code.find(params[:id])

    render json: @code
  end

  # POST /codes
  # POST /codes.json
  def create
    @code = Code.new(params[:code])

    if @code.save
      store = Store.find(@code.store_id);
      order = Order.create!(
        amount: 0,
        survey_worth: 0,
        code_id: @code.id,
        store_id: store.id,
        company_id: store.company.id,
      )
      render json: @code, status: :created, location: @code
    else
      render json: @code.errors, status: :unprocessable_entity
    end

  end

  # PATCH/PUT /codes/1
  # PATCH/PUT /codes/1.json
  def update
    @code = Code.find(params[:id])

    if @code.update_attributes(params[:code])
      head :no_content
    else
      render json: @code.errors, status: :unprocessable_entity
    end
  end

  # DELETE /codes/1
  # DELETE /codes/1.json
  def destroy
    @code = Code.find(params[:id])
    @code.active = false

    if @code.save
      head :no_content
    else
      render json: @code.errors, status: :unprocessable_entity
    end
  end

  # POST /codes/scan
  # POST /codes/scan.json
  def scan
    @code = Code.where(qr: params[:qr]).limit(1).first
    unless @code.nil?
      @code.used += 1
      @code.last_used_time = Time.now.utc

      if @code.created_at + 2.days < @code.last_used_time
        @code.active = false unless @code.static
      end

      if @code.active
        @code.active = false unless @code.static
        if @code.save
          survey = MemberSurvey.create_from_code(@code, params[:member_id])
          render json: survey.to_json(:include => { 
            :member_survey_answers => { 
              :include => { 
                :survey_question => {
                  :only => [ :answer_type, :answer_meta ],
                },
              },
            }, 
            :company  => {},
          })
        else
          render json: @code.errors, status: :unprocessable_entity
        end
      else
        if @code.save
          render json: [ { code: "Already used or expired" } ], status: :unprocessable_entity
        else
          render json: @code.errors, status: :unprocessable_entity
        end
      end
    else
      render json: [ { code: "Not Found" } ], status: :unprocessable_entity
    end
  end
end
