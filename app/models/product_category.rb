class ProductCategory < ActiveRecord::Base
  attr_accessible :name

  has_many :products, inverse_of: :product_category
end
