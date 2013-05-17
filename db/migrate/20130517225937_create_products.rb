class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.string :size
      t.string :company_id

      t.timestamps
    end
  end
end
