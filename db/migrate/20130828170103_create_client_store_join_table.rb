class CreateClientStoreJoinTable < ActiveRecord::Migration
  def change
    create_table :clients_stores, :id => false do |t|
      t.integer :client_id
      t.integer :store_id
    end
  end
end
