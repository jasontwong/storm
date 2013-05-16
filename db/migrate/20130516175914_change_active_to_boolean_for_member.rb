class ChangeActiveToBooleanForMember < ActiveRecord::Migration
  def up
    change_column :members, :active, :boolean, :default => 1
  end

  def down
    change_column :members, :active, :integer
  end
end
