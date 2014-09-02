class CreateStoreGroups < ActiveRecord::Migration
  def change
    create_table :store_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
