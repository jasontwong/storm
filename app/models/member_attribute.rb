class MemberAttribute < ActiveRecord::Base
  # attr_accessible :member_id, :name, :value
  belongs_to :member, inverse_of: :member_attributes

  validates :member, presence: true
  validates :name, presence: true
  validates_uniqueness_of :member_id, scope: :name
end
