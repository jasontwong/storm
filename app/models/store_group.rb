class StoreGroup < ActiveRecord::Base
  has_many :stores, inverse_of: :store_group
  has_many :rewards, inverse_of: :store_group
  has_many :member_points, inverse_of: :store_group
end
