class AddLastUsedTimeToCode < ActiveRecord::Migration
  def change
    add_column :codes, :last_used_time, :datetime
  end
end
