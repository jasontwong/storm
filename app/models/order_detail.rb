class OrderDetail < ActiveRecord::Base
  attr_accessible :code_id, :discount, :name, :order_id, :price, :product_id, :quantity

  belongs_to :code, inverse_of: :order_details
  belongs_to :order, inverse_of: :order_details
  belongs_to :product, inverse_of: :order_details

  validates :code_id, presence: :true
  validates :name, presence: :true
  validates :order_id, presence: :true
  validates :price, presence: :true
  validates :quantity, presence: :true
end
