class AddUsedToCode < ActiveRecord::Migration
  def change
    add_column :codes, :used, :integer
    add_column :codes, :active, :boolean
  end
end
