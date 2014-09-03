class AddStoreGroupIdToStores < ActiveRecord::Migration
  def change
    add_column :stores, :store_group_id, :integer
    add_index :stores, :store_group_id
  end
end
