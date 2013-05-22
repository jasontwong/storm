class CreateSurveyQuestionCategories < ActiveRecord::Migration
  def change
    create_table :survey_question_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
