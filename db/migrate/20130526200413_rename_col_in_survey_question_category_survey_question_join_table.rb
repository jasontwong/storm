class RenameColInSurveyQuestionCategorySurveyQuestionJoinTable < ActiveRecord::Migration
  def up
    rename_column :survey_question_categories_survey_questions, :usrvey_question_category_id, :survey_question_category_id
  end

  def down
    rename_column :survey_question_categories_survey_questions, :survey_question_category_id, :usrvey_question_category_id
  end
end
