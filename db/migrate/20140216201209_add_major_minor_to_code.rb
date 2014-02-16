class AddMajorMinorToCode < ActiveRecord::Migration
  def change
    add_column :codes, :major, :integer
    add_column :codes, :minor, :integer
  end
end
