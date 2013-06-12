class RenameTableClientClientPermissionToClientPermissionClient < ActiveRecord::Migration
  def change
    rename_table(:clients_client_permissions, :client_permssions_clients)
  end
end
