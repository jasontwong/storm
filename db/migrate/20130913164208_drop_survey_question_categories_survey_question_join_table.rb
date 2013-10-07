class DropSurveyQuestionCategoriesSurveyQuestionJoinTable < ActiveRecord::Migration
  def up
    drop_table :survey_question_categories_survey_questions
  end

  def down
    create_table "survey_question_categories_survey_questions", :id => false, :force => true do |t|
      t.integer "survey_question_category_id"
      t.integer "survey_question_id"
    end
  end
end
