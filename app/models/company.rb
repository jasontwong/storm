class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone

  has_many :stores
  has_many :products

  validates :name, presence: true
end
