class LinkRewardsAndPointsToStoreGroup < ActiveRecord::Migration
  def change
    rename_column :member_points, :company_id, :store_group_id
    rename_column :rewards, :company_id, :store_group_id
  end
end
