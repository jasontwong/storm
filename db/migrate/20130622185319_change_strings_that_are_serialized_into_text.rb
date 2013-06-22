class ChangeStringsThatAreSerializedIntoText < ActiveRecord::Migration
  def up
    change_column :survey_questions, :dynamic_meta, :text
  end

  def down
    change_column :survey_questions, :dynamic_meta, :string
  end
end
