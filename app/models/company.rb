class Company < ActiveRecord::Base
  WORTH_TYPE_FLAT = 1
  WORTH_TYPE_PRICE = 2
  attr_accessible :description, :location, :logo, :name, :phone, :survey_question_limit, :html, :worth_type, :worth_meta

  has_many :stores, inverse_of: :company
  has_many :products, inverse_of: :company
  has_many :rewards, inverse_of: :company
  has_many :orders, inverse_of: :company
  has_many :surveys, inverse_of: :company
  has_many :survey_questions, inverse_of: :company
  has_many :member_points, inverse_of: :company
  has_many :member_surveys, inverse_of: :company
  has_many :clients, inverse_of: :company

  serialize :logo, Hash
  serialize :worth_meta, Hash

  validates :name, presence: true

  after_initialize :init

  def init
    self.worth_type = Company::WORTH_TYPE_FLAT
    self.worth_meta = { worth: 5 }
    self.survey_question_limit = 5 if self.survey_question_limit.nil?
  end
end
