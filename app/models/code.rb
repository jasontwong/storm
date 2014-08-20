class Code < ActiveRecord::Base
  belongs_to :store, inverse_of: :codes
  has_many :member_answers, inverse_of: :code
  has_many :member_surveys, inverse_of: :code

  validates :active, inclusion: { in: [ true, false ] }
  validates :static, inclusion: { in: [ true, false ] }
  validates :used, presence: true
  validates :store_id, presence: true

  after_initialize :init
  
  def init
    self.used = 0 if self.used.nil?
    self.static = false if self.static.nil?
  end
end
