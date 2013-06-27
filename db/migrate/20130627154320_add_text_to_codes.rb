class AddTextToCodes < ActiveRecord::Migration
  def change
    add_column :codes, :text, :text
  end
end
