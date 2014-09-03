class Reward < ActiveRecord::Base
  belongs_to :store_group, inverse_of: :rewards
  has_many :member_rewards, inverse_of: :reward

  after_initialize :init

  serialize :images, Hash

  validates :store_group_id, presence: true
  validates :cost, presence: true
  validates :title, presence: true
  validates :uses_left, presence: true

  # {{{ def init
  def init
    self.uses_left = -1 if self.uses_left.nil?
  end

  # }}}
  # {{{ def expired?
  def expired?
    now = Time.now.utc
    return true if self.uses_left == 0
    unless self.starts.nil?
      return true if self.starts > now
      return self.expires < now if !self.expires.nil?
    end
    return false
  end
  
  # }}}
end
