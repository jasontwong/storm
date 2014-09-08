class CreateMemberProfiles < ActiveRecord::Migration
  def change
    create_table :member_profiles do |t|

      t.timestamps
    end
  end
end
