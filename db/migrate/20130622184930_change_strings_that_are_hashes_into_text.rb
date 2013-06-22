class ChangeStringsThatAreHashesIntoText < ActiveRecord::Migration
  def up
    change_column :companies, :logo, :text
    change_column :survey_questions, :answer_meta, :text
    change_column :rewards, :images, :text
  end

  def down
    change_column :companies, :logo, :string
    change_column :survey_questions, :answer_meta, :string
    change_column :rewards, :images, :string
  end
end
