class ChangeFbidToBigIntForMember < ActiveRecord::Migration
  def up
    change_column :members, :fb_id, :integer, limit: 8
  end

  def down
  end
end
