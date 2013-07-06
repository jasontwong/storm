class AddFbidToMember < ActiveRecord::Migration
  def change
    add_column :members, :fb_id, :integer
  end
end
