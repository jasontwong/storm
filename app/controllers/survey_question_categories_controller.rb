class SurveyQuestionCategoriesController < ApplicationController
  # GET /survey_question_categories
  # GET /survey_question_categories.json
  def index
    @survey_question_categories = SurveyQuestionCategory.all

    render json: @survey_question_categories
  end

  # GET /survey_question_categories/1
  # GET /survey_question_categories/1.json
  def show
    @survey_question_category = SurveyQuestionCategory.find(params[:id])

    render json: @survey_question_category
  end

  # POST /survey_question_categories
  # POST /survey_question_categories.json
  def create
    @survey_question_category = SurveyQuestionCategory.new(params[:survey_question_category])

    if @survey_question_category.save
      render json: @survey_question_category, status: :created, location: @survey_question_category
    else
      render json: @survey_question_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /survey_question_categories/1
  # PATCH/PUT /survey_question_categories/1.json
  def update
    @survey_question_category = SurveyQuestionCategory.find(params[:id])

    if @survey_question_category.update_attributes(params[:survey_question_category])
      head :no_content
    else
      render json: @survey_question_category.errors, status: :unprocessable_entity
    end
  end

  # DELETE /survey_question_categories/1
  # DELETE /survey_question_categories/1.json
  def destroy
    @survey_question_category = SurveyQuestionCategory.find(params[:id])
    @survey_question_category.destroy

    head :no_content
  end
end
