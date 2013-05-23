class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone

  has_many :stores, inverse_of: :company
  has_many :products, inverse_of: :company
  has_many :rewards, inverse_of: :company
  has_many :orders, inverse_of: :company
  has_many :survey_questions, inverse_of: :company
  has_many :member_points, inverse_of: :company

  validates :name, presence: true
end
