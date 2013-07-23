class SurveysController < ApplicationController
  # GET /surveys
  # GET /surveys.json
  def index
    @surveys = Survey.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @surveys.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /surveys/1
  # GET /surveys/1.json
  def show
    @survey = Survey.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @survey.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /surveys
  # POST /surveys.json
  def create
    @survey = Survey.new(params[:survey])

    @survey.survey_questions = SurveyQuestion.where(id: params[:question_ids]) if params[:question_ids].present?
    @survey.stores = Store.where(id: params[:store_ids]) if params[:store_ids].present?

    if @survey.save
      render json: @survey, status: :created, location: @survey
    else
      render json: @survey.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /surveys/1
  # PATCH/PUT /surveys/1.json
  def update
    @survey = Survey.find(params[:id])

    @survey.survey_questions = SurveyQuestion.where(id: params[:question_ids]) if params[:question_ids].present?
    @survey.stores = Store.where(id: params[:store_ids]) if params[:store_ids].present?

    if @survey.update_attributes(params[:survey])
      head :no_content
    else
      render json: @survey.errors, status: :unprocessable_entity
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.json
  def destroy
    @survey = Survey.find(params[:id])
    @survey.destroy

    head :no_content
  end
end
