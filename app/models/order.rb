class Order < ActiveRecord::Base
  attr_accessible :amount, :checkin_worth, :code_id, :company_id, :member_id, :server, :store_id, :survey_worth

  belongs_to :code, inverse_of: :orders
  belongs_to :company, inverse_of: :orders
  belongs_to :store, inverse_of: :orders
  belongs_to :member, inverse_of: :orders
  has_many :order_details, inverse_of: :order

  validates :amount, presence: true
  validates :code_id, presence: true
  validates :company_id, presence: true
  validates :store_id, presence: true
  validates :survey_worth, presence: true
end
