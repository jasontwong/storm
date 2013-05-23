class CreateMemberPoints < ActiveRecord::Migration
  def change
    create_table :member_points do |t|
      t.integer :member_id
      t.integer :company_id
      t.decimal :points
      t.decimal :total_points
      t.datetime :last_earned

      t.timestamps
    end
  end
end
