class AddImagesToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :images, :string
  end
end
