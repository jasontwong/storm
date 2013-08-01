class RenameTypeToModelActionForChangelog < ActiveRecord::Migration
  def up
    rename_column :changelogs, :type, :model_action
  end

  def down
    rename_column :changelogs, :model_action, :type
  end
end
