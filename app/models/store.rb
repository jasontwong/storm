class Store < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :company_id, :country, :latitude, :longitude, :name, :phone, :state, :zip

  belongs_to :company, inverse_of: :stores
  has_and_belongs_to_many :surveys
  has_many :codes, inverse_of: :store
  has_many :surveys, inverse_of: :store
  has_many :survey_questions, through: :surveys
  has_many :orders, inverse_of: :store
  has_many :member_rewards, inverse_of: :store
  has_many :member_surveys, inverse_of: :store

  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :company_id, presence: true
  validates :country, presence: true
  validates :name, presence: true
  validates :zip, presence: true
  validates :phone, presence: true
end
