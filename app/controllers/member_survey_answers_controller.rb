class MemberSurveyAnswersController < ApplicationController
  # GET /member_survey_answers
  # GET /member_survey_answers.json
  def index
    @member_survey_answers = MemberSurveyAnswer.all

    render json: @member_survey_answers
  end

  # GET /member_survey_answers/1
  # GET /member_survey_answers/1.json
  def show
    @member_survey_answer = MemberSurveyAnswer.find(params[:id])

    render json: @member_survey_answer
  end

  # POST /member_survey_answers
  # POST /member_survey_answers.json
  def create
    @member_survey_answer = MemberSurveyAnswer.new(params[:member_survey_answer])

    if @member_survey_answer.save
      render json: @member_survey_answer, status: :created, location: @member_survey_answer
    else
      render json: @member_survey_answer.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /member_survey_answers/1
  # PATCH/PUT /member_survey_answers/1.json
  def update
    @member_survey_answer = MemberSurveyAnswer.find(params[:id])

    if @member_survey_answer.update_attributes(params[:member_survey_answer])
      head :no_content
    else
      render json: @member_survey_answer.errors, status: :unprocessable_entity
    end
  end

  # DELETE /member_survey_answers/1
  # DELETE /member_survey_answers/1.json
  def destroy
    @member_survey_answer = MemberSurveyAnswer.find(params[:id])
    @member_survey_answer.destroy

    head :no_content
  end
end
