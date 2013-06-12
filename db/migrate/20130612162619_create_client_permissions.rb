class CreateClientPermissions < ActiveRecord::Migration
  def change
    create_table :client_permissions do |t|
      t.string :name

      t.timestamps
    end
  end
end
