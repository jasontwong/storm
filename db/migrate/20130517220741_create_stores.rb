class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :company_id
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :phone
      t.string :latitude
      t.string :longitude

      t.timestamps
    end
  end
end
