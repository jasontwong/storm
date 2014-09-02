class StoreGroup < ActiveRecord::Base
  has_many :stores, inverse_of: :store_group
end
