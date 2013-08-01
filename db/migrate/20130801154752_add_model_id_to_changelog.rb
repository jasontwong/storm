class AddModelIdToChangelog < ActiveRecord::Migration
  def change
    add_column :changelogs, :model_id, :integer
  end
end
