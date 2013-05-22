class SurveyQuestionCategory < ActiveRecord::Base
  attr_accessible :name

  has_and_belongs_to_many :survery_questions

  validates :name, presence: true
end
