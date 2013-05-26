class CreateSurveyQuestionSurveyJoinTable < ActiveRecord::Migration
  def change
    create_table :survey_questions_surveys, :id => false do |t|
      t.integer :survey_question_id
      t.integer :survey_id
    end
  end
end
