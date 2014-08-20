class ProductCategory < ActiveRecord::Base
  has_many :products, inverse_of: :product_category
end
