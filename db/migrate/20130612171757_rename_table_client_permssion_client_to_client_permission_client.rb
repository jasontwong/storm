class RenameTableClientPermssionClientToClientPermissionClient < ActiveRecord::Migration
  def change
    rename_table(:client_permssions_clients, :client_permissions_clients)
  end
end
