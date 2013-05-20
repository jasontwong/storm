class CreateSurveyQuestions < ActiveRecord::Migration
  def change
    create_table :survey_questions do |t|
      t.integer :survey_id
      t.string :question
      t.string :answer_type
      t.string :answer_meta
      t.boolean :active

      t.timestamps
    end
  end
end
