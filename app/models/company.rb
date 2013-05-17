class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone

  has_many :stores

  validates :name, presence: true
end
