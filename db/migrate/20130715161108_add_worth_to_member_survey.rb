class AddWorthToMemberSurvey < ActiveRecord::Migration
  def change
    add_column :member_surveys, :worth, :decimal
  end
end
