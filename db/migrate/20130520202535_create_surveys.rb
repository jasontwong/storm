class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :company_id
      t.string :title
      t.string :description
      t.boolean :default

      t.timestamps
    end
  end
end
