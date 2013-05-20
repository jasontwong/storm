class Product < ActiveRecord::Base
  attr_accessible :company_id, :name, :price, :size

  belongs_to :company, inverse_of: :products
  has_and_belongs_to_many :survey_questions

  validates :company_id, presence: true
  validates :name, presence: true
  validates :price, presence: true
end
