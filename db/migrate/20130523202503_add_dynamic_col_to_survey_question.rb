class AddDynamicColToSurveyQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :dynamic, :boolean
  end
end
