class AddTempPasswordToClients < ActiveRecord::Migration
  def change
    add_column :clients, :temp_password, :string
  end
end
