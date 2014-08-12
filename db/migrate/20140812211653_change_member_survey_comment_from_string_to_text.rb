class ChangeMemberSurveyCommentFromStringToText < ActiveRecord::Migration
  def up
    change_column :member_surveys, :comments, :text
  end

  def down
    change_column :member_surveys, :comments, :string
  end
end
