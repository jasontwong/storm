class AddDynamicMetaToSurveyQuestion < ActiveRecord::Migration
  def change
    add_column :survey_questions, :dynamic_meta, :string
  end
end
