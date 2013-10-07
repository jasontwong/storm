class AddStoreIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :store_id, :integer
  end
end
