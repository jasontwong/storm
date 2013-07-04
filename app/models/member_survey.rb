class MemberSurvey < ActiveRecord::Base
  attr_accessible :code_id, :company_id, :member_id, :order_id, :store_id

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
end
