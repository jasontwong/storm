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

  before_create :find_same_product
  before_save :find_same_product

  def find_same_product
    if self.product_id.nil?
      detail = OrderDetail.joins(:order).where(orders: { company_id: self.order.company_id }, name: self.name).where('product_id IS NOT NULL').first
      
      unless detail.nil?
        self.product_id = detail.product_id
      end
    end
  end

end
