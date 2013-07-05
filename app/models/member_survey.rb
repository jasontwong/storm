class MemberSurvey < ActiveRecord::Base
  attr_accessible :code_id, :company_id, :member_id, :order_id, :store_id, :completed, :completed_time

  belongs_to :code, inverse_of: :member_surveys
  belongs_to :company, inverse_of: :member_surveys
  belongs_to :member, inverse_of: :member_surveys
  belongs_to :order, inverse_of: :member_survey
  belongs_to :store, inverse_of: :member_surveys
  has_many :member_survey_answers, inverse_of: :member_survey

  validates :code_id, presence: true
  validates :company_id, presence: true
  validates :member_id, presence: true
  validates :order_id, presence: true
  validates :store_id, presence: true
  validates :completed, :inclusion => { :in => [true, false] }

  def self.create_from_code(code, member_id)
    survey = MemberSurvey.create!(
      code_id: code.id,
      company_id: code.store.company.id,
      member_id: member_id,
      order_id: code.order.id,
      store_id: code.store_id,
    )
    questions = []
    code.surveys.each do |suvery|
      if survey.default
        survey.survey_questions.each do |question|
          if questions.length <= code.store.company.survey_question_limit
            questions << MemberSurveyAnswer.create!(
              member_survey_id: member_survey.id,
              survey_question_id: question.id,
              question: question.build_question,
            )
          else
            break
          end
        end
        break
      end
    end
  end

end
