class AddReceiptTypeToStore < ActiveRecord::Migration
  def change
    add_column :stores, :receipt_type, :integer
  end
end
