class AddSurveyQuestionCategoryIdToSurveyQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :survey_question_category_id, :integer
  end
end
