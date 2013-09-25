class AddParentIdToSurveyQuestionCategory < ActiveRecord::Migration
  def change
    add_column :survey_question_categories, :parent_id, :integer
  end
end
