class AddMemberIdToMemberProfiles < ActiveRecord::Migration
  def change
    add_column :member_profiles, :member_id, :integer

    add_index :member_profiles, :member_id, unique: true
  end
end
