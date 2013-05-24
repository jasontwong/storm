class CreateMemberRewards < ActiveRecord::Migration
  def change
    create_table :member_rewards do |t|
      t.integer :member_id
      t.integer :reward_id
      t.boolean :redeemed
      t.integer :store_id
      t.integer :printed
      t.integer :scanned
      t.string :code
      t.binary :bcode
      t.datetime :redeemed_time

      t.timestamps
    end
  end
end
