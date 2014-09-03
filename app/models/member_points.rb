class MemberPoints < ActiveRecord::Base
  belongs_to :member, inverse_of: :member_points
  belongs_to :store_group, inverse_of: :member_points

  validates :store_group_id, presence: true
  validates :member_id, presence: true

  after_initialize :init

  def init
    self.points = 0 if self.points.nil?
    self.total_points = 0 if self.total_points.nil?
  end
end
