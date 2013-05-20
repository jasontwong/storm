class CreateProductSurveyQuestionJoinTable < ActiveRecord::Migration
  def change
    create_table :products_survey_questions, :id => false do |t|
      t.integer :product_id
      t.integer :survey_question_id
    end
  end
end
