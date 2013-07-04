class MemberSurveyAnswer < ActiveRecord::Base
  attr_accessible :answer, :member_survey_id, :question

  belongs_to :member_survey, inverse_of: :member_survey_answers

  validates :member_survey_id, presence: true
  validates :question, presence: true
end
