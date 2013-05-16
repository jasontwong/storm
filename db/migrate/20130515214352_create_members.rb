class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :email
      t.string :password
      t.string :salt
      t.string :fb_username
      t.string :fb_password
      t.integer :active

      t.timestamps
    end
  end
end
