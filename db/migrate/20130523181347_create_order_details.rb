class CreateOrderDetails < ActiveRecord::Migration
  def change
    create_table :order_details do |t|
      t.integer :order_id
      t.integer :product_id
      t.string :name
      t.integer :quantity
      t.decimal :discount
      t.integer :code_id
      t.decimal :price

      t.timestamps
    end
  end
end
