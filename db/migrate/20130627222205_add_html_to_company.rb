class AddHtmlToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :html, :text
  end
end
