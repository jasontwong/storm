class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone

  has_many :stores
  has_many :products
  has_many :rewards
  has_many :surveys

  validates :name, presence: true
end
