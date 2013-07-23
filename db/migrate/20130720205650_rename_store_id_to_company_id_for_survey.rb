class RenameStoreIdToCompanyIdForSurvey < ActiveRecord::Migration
  def up
    rename_column :surveys, :store_id, :company_id
  end

  def down
    rename_column :surveys, :company_id, :store_id
  end
end
