class CreateMemberSurveys < ActiveRecord::Migration
  def change
    create_table :member_surveys do |t|
      t.integer :code_id
      t.integer :member_id
      t.integer :order_id
      t.integer :company_id
      t.integer :store_id

      t.timestamps
    end
  end
end
