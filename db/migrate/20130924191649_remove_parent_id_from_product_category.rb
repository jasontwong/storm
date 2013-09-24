class RemoveParentIdFromProductCategory < ActiveRecord::Migration
  def up
    remove_column :product_categories, :parent_id
  end

  def down
    add_column :product_categories, :parent_id, :integer
  end
end
