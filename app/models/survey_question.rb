class SurveyQuestion < ActiveRecord::Base
  attr_accessible :answer_meta, :answer_type, :question, :survey_id, :active

  belongs_to :survey, inverse_of: :survey_questions
  has_and_belongs_to_many :products
  has_and_belongs_to_many :survery_question_categories

  validates :answer_type, presence: true
  validates :question, presence: true
  validates :survey_id, presence: true
  validates :active, :inclusion => { :in => [true, false] }
end
