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
    codes = Code.where(qr: params[:qr]).limit(1)
    if codes.length == 1
      @code = codes[0]
      @code.used += 1
      @code.last_used_time = Time.now.utc

      if @code.active
        @code.active = false
        if @code.save
          render json: SurveyQuestion.by_code(@code)
        else
          render json: @code.errors, status: :unprocessable_entity
        end
      else
        if @code.save
          render json: [ { code: "Already used" } ], status: :unprocessable_entity
        else
          render json: @code.errors, status: :unprocessable_entity
        end
      end
    else
      render json: [ { code: "Not Found" } ], status: :unprocessable_entity
    end
  end
end
