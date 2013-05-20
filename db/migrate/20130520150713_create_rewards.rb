class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :company_id
      t.string :title
      t.string :description
      t.integer :cost
      t.datetime :starts
      t.datetime :expires
      t.integer :uses_left

      t.timestamps
    end
  end
end
