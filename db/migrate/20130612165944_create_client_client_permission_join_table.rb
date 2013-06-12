class CreateClientClientPermissionJoinTable < ActiveRecord::Migration
  def change
    create_table :clients_client_permissions, :id => false do |t|
      t.integer :client_id
      t.integer :client_permission_id
    end
  end
end
