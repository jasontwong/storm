class AddTosToClients < ActiveRecord::Migration
  def change
    add_column :clients, :tos, :boolean
  end
end
