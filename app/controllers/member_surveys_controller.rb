class MemberSurveysController < ApplicationController
  # GET /member_surveys
  # GET /member_surveys.json
  def index
    @member_surveys = MemberSurvey.all

    render json: @member_surveys
  end

  # GET /member_surveys/1
  # GET /member_surveys/1.json
  def show
    @member_survey = MemberSurvey.find(params[:id])

    render json: @member_survey
  end

  # POST /member_surveys
  # POST /member_surveys.json
  def create
    @member_survey = MemberSurvey.new(params[:member_survey])

    if @member_survey.save
      render json: @member_survey, status: :created, location: @member_survey
    else
      render json: @member_survey.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /member_surveys/1
  # PATCH/PUT /member_surveys/1.json
  def update
    @member_survey = MemberSurvey.find(params[:id])

    if @member_survey.update_attributes(params[:member_survey])
      head :no_content
    else
      render json: @member_survey.errors, status: :unprocessable_entity
    end
  end

  # DELETE /member_surveys/1
  # DELETE /member_surveys/1.json
  def destroy
    @member_survey = MemberSurvey.find(params[:id])
    @member_survey.destroy

    head :no_content
  end
end
