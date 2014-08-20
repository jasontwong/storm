class SurveyQuestion < ActiveRecord::Base
  belongs_to :company, inverse_of: :survey_questions
  belongs_to :survey_question_category, inverse_of: :survey_questions
  has_many :member_survey_answers, inverse_of: :survey_question
  has_and_belongs_to_many :surveys

  serialize :answer_meta, Hash
  serialize :dynamic_meta, Array

  validates :answer_type, presence: true
  validates :question, presence: true
  validates :company_id, presence: true
  validates :active, :inclusion => { :in => [true, false] }
  validates :dynamic, :inclusion => { :in => [true, false] }

  def build_question(code)
    question = self.question

    return question

  end

end
