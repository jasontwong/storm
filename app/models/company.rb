class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone

  validates :name, presence: true
end
