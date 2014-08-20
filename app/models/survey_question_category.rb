class SurveyQuestionCategory < ActiveRecord::Base
  belongs_to :parent, :class_name => "SurveyQuestionCategory"
  has_many :children, :class_name => "SurveyQuestionCategory", :foreign_key => 'parent_id'
  has_many :survey_questions, inverse_of: :survey_question_category

  validates :name, presence: true
end
