class CreateClientGroups < ActiveRecord::Migration
  def change
    create_table :client_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
