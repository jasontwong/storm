class AddCompletedAndCompletedTimeToMemberSurvey < ActiveRecord::Migration
  def change
    add_column :member_surveys, :completed, :boolean
    add_column :member_surveys, :completed_time, :datetime
  end
end
