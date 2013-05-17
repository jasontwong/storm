class Product < ActiveRecord::Base
  attr_accessible :company_id, :name, :price, :size

  belongs_to :company

  validates :company_id, presence: true
  validates :name, presence: true
  validates :price, presence: true
end
