class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.integer :company_id
      t.string :email
      t.string :password
      t.integer :client_group_id
      t.string :name
      t.string :salt
      t.boolean :active

      t.timestamps
    end
  end
end
