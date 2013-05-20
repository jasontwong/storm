class CreateStoreSurveyJoinTable < ActiveRecord::Migration
  def change
    create_table :stores_surveys, :id => false do |t|
      t.integer :store_id
      t.integer :survey_id
    end
  end
end
