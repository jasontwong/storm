class MemberSurveyAnswer < ActiveRecord::Base
  belongs_to :member_survey, inverse_of: :member_survey_answers
  belongs_to :survey_question, inverse_of: :member_survey_answers
  belongs_to :product, inverse_of: :member_survey_answers

  validates :member_survey_id, presence: true
  validates :question, presence: true
end
