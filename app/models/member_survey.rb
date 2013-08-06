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
    order = code.order
    worth = 0

    case company.worth_type
    when Company::WORTH_TYPE_FLAT
      worth = company.worth_meta[:worth]
    when Company::WORTH_TYPE_PRICE
      worth = order.survey_worth
    end

    survey = MemberSurvey.create!(
      code_id: code.id,
      company_id: company.id,
      member_id: member_id,
      order_id: order.id,
      store_id: store.id,
      completed: false,
      worth: worth,
    )
    questions = []

    store.surveys.each do |s|
      store_survey ||= s
      break
    end

    store_survey ||= company.surveys.first
    questions = []

    store_survey.survey_questions.each do |question|
      q = question.build_question(code)

      questions << {
        id: question.id,
        question: q,
      } unless q.nil?
    end

    questions.sample(company.survey_question_limit).each do |question|
      MemberSurveyAnswer.create!(
        member_survey_id: survey.id,
        survey_question_id: question.id,
        question: question.question,
      )
    end

    return survey

  end

end
