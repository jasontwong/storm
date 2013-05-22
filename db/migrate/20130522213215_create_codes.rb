class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.string :qr

      t.timestamps
    end
  end
end
