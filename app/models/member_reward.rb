class MemberReward < ActiveRecord::Base
  ALPHA = 1
  ALPHANUMERIC = 2
  NUMERIC = 3
  BAR = 4

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

  def generate_code (type, complexity=5)
    case type
    when ALPHA # letters only
    when ALPHANUMERIC # letters and numbers
      self.code = SecureRandom.hex.upcase[0..complexity-1]
    when NUMERIC # numbers only
    when BAR # bar code
    end
  end
end
