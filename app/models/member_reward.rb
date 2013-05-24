class MemberReward < ActiveRecord::Base
  attr_accessible :bcode, :code, :printed, :redeemed, :redeemed_time, :reward_id, :scanned, :store_id, :member_id

  belongs_to :member, inverse_of: :member_rewards
  belongs_to :reward, inverse_of: :member_rewards
  belongs_to :store, inverse_of: :member_rewards

  validates :redeemed, inclusion: [ true, false ]
  validates :member_id, presence: true
  validates :reward_id, presence: true

  after_initialize :init

  def init
    self.printed = 0 if self.printed.nil?
    self.scanned = 0 if self.scanned.nil?
  end
end
