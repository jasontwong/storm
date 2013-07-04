class AddSurveyQuestionIdToMemberSurveyAnswer < ActiveRecord::Migration
  def change
    add_column :member_survey_answers, :survey_question_id, :integer
  end
end
