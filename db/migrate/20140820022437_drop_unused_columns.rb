class DropUnusedColumns < ActiveRecord::Migration
  def up
    change_table :member_surveys do |t|
      t.remove :order_id
    end
  end

  def down
    change_table :member_surveys do |t|
      t.integer :order_id
    end
  end
end
