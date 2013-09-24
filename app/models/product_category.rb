class ProductCategory < ActiveRecord::Base
  attr_accessible :name, :parent_id

  belongs_to :parent, :class_name => "ProductCategory"
  has_many :children, :class_name => "ProductCategory", :foreign_key => 'parent_id'
  has_many :products, inverse_of: :product_category
end
