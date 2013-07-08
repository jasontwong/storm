class AddCommentsToMemberSurvey < ActiveRecord::Migration
  def change
    add_column :member_surveys, :comments, :string
  end
end
