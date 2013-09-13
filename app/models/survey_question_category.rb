class SurveyQuestionCategory < ActiveRecord::Base
  attr_accessible :name

  has_many :survey_questions, inverse_of: :survey_question_category

  validates :name, presence: true
end
