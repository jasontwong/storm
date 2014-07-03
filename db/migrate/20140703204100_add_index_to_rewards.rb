class AddIndexToRewards < ActiveRecord::Migration
  def change
    add_index :rewards, :company_id
  end
end
