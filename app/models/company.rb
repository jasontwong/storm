class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone, :survey_question_limit, :html

  has_many :stores, inverse_of: :company
  has_many :products, inverse_of: :company
  has_many :rewards, inverse_of: :company
  has_many :orders, inverse_of: :company
  has_many :survey_questions, inverse_of: :company
  has_many :member_points, inverse_of: :company
  has_many :member_surveys, inverse_of: :company
  has_many :clients, inverse_of: :company

  serialize :logo, Hash

  validates :name, presence: true

  after_initialize :init

  def init
    self.survey_question_limit = 5 if self.survey_question_limit.nil?
  end
end
