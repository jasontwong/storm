class AddIndexToCompany < ActiveRecord::Migration
  def change
    add_index :companies, :active
  end
end
