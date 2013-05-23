class FixSurveyIdForSurveySurveyQuestionJoinTable < ActiveRecord::Migration
  def up
    rename_column :surveys_survey_questions, :usrvey_id, :survey_id
  end

  def down
    rename_column :surveys_survey_questions, :survey_id, :usrvey_id
  end
end
