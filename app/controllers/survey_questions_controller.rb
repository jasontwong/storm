class SurveyQuestionsController < ApplicationController
  # GET /survey_questions
  # GET /survey_questions.json
  def index
    @survey_questions ||= SurveyQuestion.all

    params[:include] = [] unless params[:include].is_a? Array

    render json: @survey_questions.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # GET /survey_questions/1
  # GET /survey_questions/1.json
  def show
    @survey_question = SurveyQuestion.find(params[:id])

    params[:include] = [] unless params[:include].is_a? Array

    render json: @survey_question.to_json(:include => params[:include].collect { |data| data.to_sym })
  end

  # POST /survey_questions
  # POST /survey_questions.json
  def create
    @survey_question = SurveyQuestion.new(params[:survey_question])

    if @survey_question.save
      render json: @survey_question, status: :created, location: @survey_question
    else
      render json: @survey_question.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /survey_questions/1
  # PATCH/PUT /survey_questions/1.json
  def update
    @survey_question = SurveyQuestion.find(params[:id])

    if @survey_question.update_attributes(params[:survey_question])
      head :no_content
    else
      render json: @survey_question.errors, status: :unprocessable_entity
    end
  end

  # DELETE /survey_questions/1
  # DELETE /survey_questions/1.json
  def destroy
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_question.active = false

    if @survey_question.save
      head :no_content
    else
      render json: @survey_question.errors, status: :unprocessable_entity
    end
  end
end
