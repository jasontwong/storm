class MemberSurvey < ActiveRecord::Base
  attr_accessible :code_id, :company_id, :member_id, :order_id, :store_id, :completed, :completed_time, :comments, :worth

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

  after_initialize :init

  def init
    self.worth ||= 0
  end

  def self.create_from_code(code, member_id)
    store = code.store
    company = store.company
    worth = 0

    if company.worth_type == Company::WORTH_TYPE_FLAT
      worth = company.worth_meta[:worth]
    end

    survey = MemberSurvey.create!(
      code_id: code.id,
      company_id: company.id,
      member_id: member_id,
      order_id: code.order.id,
      store_id: store.id,
      completed: false,
      worth: worth,
    )
    questions = []
    store_survey = nil

    store.surveys.each do |s|
      store_survey ||= s
      if s.default
        store_survey = s
        break

      end
    end

    store_survey.survey_questions.each do |question|
      if questions.length < company.survey_question_limit
        questions << MemberSurveyAnswer.create!(
          member_survey_id: survey.id,
          survey_question_id: question.id,
          question: question.build_question(code),
        )

      else
        break

      end
    end

    return survey

  end

end
