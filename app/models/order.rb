class Order < ActiveRecord::Base
  attr_accessible :amount, :checkin_worth, :code_id, :company_id, :member_id, :server, :store_id, :survey_worth

  belongs_to :code, inverse_of: :order
  belongs_to :company, inverse_of: :orders
  belongs_to :store, inverse_of: :orders
  belongs_to :member, inverse_of: :orders
  has_many :order_details, inverse_of: :order

  validates :amount, presence: true
  validates :code_id, presence: true
  validates :company_id, presence: true
  validates :store_id, presence: true
  validates :survey_worth, presence: true

  def save_details(details)
    details.each do |item|
      product = Product.where(name: item[:name], company_id: self.company_id).last
      product ||= Product.new({ 
        name: item[:name], 
        price: item[:price], 
        company_id: self.company_id,
        size: item[:size],
      })
      success = product.save if product.id.nil?
      detail = OrderDetail.new(item)
      detail.order = self
      detail.product = product if success
      detail.code = self.code
      detail.save
    end
  end
end
