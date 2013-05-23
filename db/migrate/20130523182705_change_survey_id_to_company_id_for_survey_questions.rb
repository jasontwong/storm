class ChangeSurveyIdToCompanyIdForSurveyQuestions < ActiveRecord::Migration
  def up
    remove_column :survey_questions, :survey_id
    add_column :survey_questions, :company_id, :integer
  end

  def down
    add_column :survey_questions, :survey_id, :integer
    remove_column :survey_questions, :company_id
  end
end
