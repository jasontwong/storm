class AddWorthToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :worth_type, :integer, limit: 1
    add_column :companies, :worth_meta, :text
  end
end
