class CreateCodeScanLocations < ActiveRecord::Migration
  def change
    create_table :code_scan_locations do |t|
      t.decimal :latitude, :precision => 10, :scale => 6
      t.decimal :longitude, :precision => 10, :scale => 6
      t.integer :member_id
      t.integer :code_id

      t.timestamps
    end
  end
end
