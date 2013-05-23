class FixSurveyQuestionCategoryId < ActiveRecord::Migration
  def up
    rename_column :survey_questions_survey_question_categories, :usrvey_question_category_id, :survey_question_category_id
  end

  def down
    rename_column :survey_questions_survey_question_categories, :survey_question_category_id, :usrvey_question_category_id
  end
end
