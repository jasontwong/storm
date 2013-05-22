class CreateSurveyQuestionSurveyQuestionCategoryJoinTable < ActiveRecord::Migration
  def change
    create_table :survey_questions_survey_question_categories, :id => false do |t|
      t.integer :survey_question_id
      t.integer :usrvey_question_category_id
    end
  end
end
