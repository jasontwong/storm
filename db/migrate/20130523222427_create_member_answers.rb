class CreateMemberAnswers < ActiveRecord::Migration
  def change
    create_table :member_answers do |t|
      t.integer :member_id
      t.integer :code_id
      t.string :question
      t.string :answer
      t.boolean :completed
      t.datetime :completed_time

      t.timestamps
    end
  end
end
