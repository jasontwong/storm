class AddStaticToCode < ActiveRecord::Migration
  def change
    add_column :codes, :static, :boolean
  end
end
