class AddIndexToStores < ActiveRecord::Migration
  def change
    add_index :stores, :company_id
  end
end
