class DropUnusedMemberColumns < ActiveRecord::Migration
  def up
    remove_column :members, :fb_username
    remove_column :members, :fb_password
    remove_column :members, :other_id
  end

  def down
    change_table "members" do |t|
      t.string   "fb_username"
      t.string   "fb_password"
      t.string   "other_id"
    end
  end
end
