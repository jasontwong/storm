class SurveyQuestionCategoriesController < ApplicationController
  # {{{ def index
  # GET /survey_question_categories
  # GET /survey_question_categories.json
  def index
    @survey_question_categories = SurveyQuestionCategory.all

    render json: @survey_question_categories
  end

  # }}}
  # {{{ def show
  # GET /survey_question_categories/1
  # GET /survey_question_categories/1.json
  def show
    @survey_question_category = SurveyQuestionCategory.find(params[:id])

    render json: @survey_question_category
  end

  # }}}
  # {{{ def create
  # POST /survey_question_categories
  # POST /survey_question_categories.json
  def create
    @survey_question_category = SurveyQuestionCategory.new(survey_question_category_params)

    if @survey_question_category.save
      render json: @survey_question_category, status: :created, location: @survey_question_category
    else
      render json: @survey_question_category.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def update
  # PATCH/PUT /survey_question_categories/1
  # PATCH/PUT /survey_question_categories/1.json
  def update
    @survey_question_category = SurveyQuestionCategory.find(params[:id])

    if @survey_question_category.update_attributes!(survey_question_category_params)
      head :no_content
    else
      render json: @survey_question_category.errors, status: :unprocessable_entity
    end
  end

  # }}}
  # {{{ def destroy
  # DELETE /survey_question_categories/1
  # DELETE /survey_question_categories/1.json
  def destroy
    @survey_question_category = SurveyQuestionCategory.find(params[:id])
    @survey_question_category.destroy

    head :no_content
  end
  
  # }}}
  private
    # {{{ def survey_question_category_params
    def survey_question_category_params
      params.require(:survey_question_category).permit(:name)
    end

    # }}}
end
