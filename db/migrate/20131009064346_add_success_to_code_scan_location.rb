class AddSuccessToCodeScanLocation < ActiveRecord::Migration
  def change
    add_column :code_scan_locations, :success, :boolean
  end
end
