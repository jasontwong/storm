class AddFullAddressToStore < ActiveRecord::Migration
  def change
    add_column :stores, :full_address, :string
  end
end
