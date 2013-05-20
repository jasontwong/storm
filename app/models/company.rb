class Company < ActiveRecord::Base
  attr_accessible :description, :location, :logo, :name, :phone

  has_many :stores
  has_many :products
  has_many :rewards
  has_many :surveys
  has_many :survey_questions, :through => :surveys

  validates :name, presence: true
end
