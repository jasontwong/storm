class CreateMemberSurveyAnswers < ActiveRecord::Migration
  def change
    create_table :member_survey_answers do |t|
      t.integer :member_survey_id
      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end
