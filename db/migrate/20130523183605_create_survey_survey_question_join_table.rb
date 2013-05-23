class CreateSurveySurveyQuestionJoinTable < ActiveRecord::Migration
  def change
    create_table :surveys_survey_questions, :id => false do |t|
      t.integer :usrvey_id
      t.integer :survey_question_id
    end
  end
end
