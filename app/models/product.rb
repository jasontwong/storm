class Product < ActiveRecord::Base
  belongs_to :parent, :class_name => "Product"
  belongs_to :product_category, inverse_of: :products
  belongs_to :company, inverse_of: :products
  has_and_belongs_to_many :survey_questions
  has_many :children, :class_name => "Product", :foreign_key => 'parent_id'
  has_many :order_details, inverse_of: :product
  has_many :orders, through: :order_details
  has_many :member_survey_answers

  validates :company_id, presence: true
  validates :name, presence: true
  validates :price, presence: true
end
