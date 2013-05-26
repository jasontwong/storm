class CreateSurveyQuestionCategorySurveyQuestionJoinTable < ActiveRecord::Migration
  def change
    create_table :survey_question_categories_survey_questions, :id => false do |t|
      t.integer :usrvey_question_category_id
      t.integer :survey_question_id
    end
  end
end
