class Store < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :company_id, :country, :latitude, :longitude, :name, :phone, :state, :zip

  belongs_to :company, inverse_of: :stores
  has_and_belongs_to_many :surveys, inverse_of: :stores
  has_many :survey_questions, through: :surveys

  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :company_id, presence: true
  validates :country, presence: true
  validates :name, presence: true
  validates :zip, presence: true
  validates :phone, presence: true
end
