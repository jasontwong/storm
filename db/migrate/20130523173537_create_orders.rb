class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :member_id
      t.integer :code_id
      t.integer :company_id
      t.integer :store_id
      t.decimal :amount
      t.decimal :survey_worth
      t.decimal :checkin_worth
      t.string :server

      t.timestamps
    end
  end
end
