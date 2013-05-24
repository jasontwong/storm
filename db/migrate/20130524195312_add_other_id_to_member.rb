class AddOtherIdToMember < ActiveRecord::Migration
  def change
    add_column :members, :other_id, :string
  end
end
