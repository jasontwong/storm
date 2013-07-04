class Code < ActiveRecord::Base
  attr_accessible :qr, :used, :active, :last_used_time, :text, :store_id

  has_one :order, inverse_of: :code
  has_one :store
  has_many :order_details, inverse_of: :code
  has_many :member_answers, inverse_of: :code
  has_many :member_surveys, inverse_of: :code

  validates :qr, presence: true
  validates :active, inclusion: { in: [ true, false ] }
  validates :used, presence: true

  after_initialize :init
  
  def init
    self.used = 0 if self.used.nil?
  end
end
