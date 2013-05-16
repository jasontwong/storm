class CreateMemberAttributes < ActiveRecord::Migration
  def change
    create_table :member_attributes do |t|
      t.integer :member_id
      t.string :name
      t.string :value
    end
  end
end
