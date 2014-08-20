class MemberAttribute < ActiveRecord::Base
  belongs_to :member, inverse_of: :member_attributes

  validates :member_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :member_id, scope: :name
end
