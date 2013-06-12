class CreateClientGroupClientPermissionJoinTable < ActiveRecord::Migration
  def change
    create_table :client_groups_client_permissions, :id => false do |t|
      t.integer :client_group_id
      t.integer :client_permission_id
    end
  end
end
