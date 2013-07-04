class AddStoreIdToCode < ActiveRecord::Migration
  def change
    add_column :codes, :store_id, :integer
  end
end
