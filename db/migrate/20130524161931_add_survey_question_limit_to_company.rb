class AddSurveyQuestionLimitToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :survey_question_limit, :integer
  end
end
