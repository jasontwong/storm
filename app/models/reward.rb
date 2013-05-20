class Reward < ActiveRecord::Base
  attr_accessible :company_id, :cost, :description, :expires, :starts, :title, :uses_left

  belongs_to :company

  after_initialize :init

  validates :company_id, presence: true
  validates :cost, presence: true
  validates :title, presence: true
  validates :uses_left, presence: true

  def init
    self.uses_left = -1
  end
end
