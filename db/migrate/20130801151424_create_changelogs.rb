class CreateChangelogs < ActiveRecord::Migration
  def change
    create_table :changelogs do |t|
      t.string :type
      t.string :model
      t.text :meta

      t.timestamps
    end
  end
end
