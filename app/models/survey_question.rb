class SurveyQuestion < ActiveRecord::Base
  attr_accessible :answer_meta, :answer_type, :question, :survey_id, :active

  belongs_to :survey, inverse_of: :survey_questions

  validates :answer_type, presence: true
  validates :question, presence: true
  validates :survey_id, presence: true
  validates :active, :inclusion => { :in => [true, false] }
end
