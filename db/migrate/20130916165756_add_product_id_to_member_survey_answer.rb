class AddProductIdToMemberSurveyAnswer < ActiveRecord::Migration
  def change
    add_column :member_survey_answers, :product_id, :integer
  end
end
