class RemoveStoreIdFromClients < ActiveRecord::Migration
  def up
    remove_column :clients, :store_id
  end

  def down
    add_column :clients, :store_id, :integer
  end
end
