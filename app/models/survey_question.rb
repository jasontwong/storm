class SurveyQuestion < ActiveRecord::Base
  attr_accessible :answer_meta, :answer_type, :question, :company_id, :active, :dynamic, :dynamic_meta

  belongs_to :company, inverse_of: :survey_questions
  has_and_belongs_to_many :products
  has_and_belongs_to_many :surveys
  has_and_belongs_to_many :survey_question_categories

  serialize :answer_meta, Hash
  serialize :dynamic_meta, Array

  validates :answer_type, presence: true
  validates :question, presence: true
  validates :company_id, presence: true
  validates :active, :inclusion => { :in => [true, false] }
  validates :dynamic, :inclusion => { :in => [true, false] }

  def self.by_code(code)
    # TODO create algorithm to give the right questions
    return self.where(company_id: 1).limit(5)
  end

end
