class Member < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :email, :password, :active, :salt, :fb_username, :fb_password

  has_many :member_attributes, inverse_of: :member
  has_many :orders, inverse_of: :member
  has_many :member_points, inverse_of: :member
  has_many :member_answers, inverse_of: :member
  has_many :member_rewards, inverse_of: :member

  validates :email, :uniqueness => true, :presence => true, :email => true
  validates :active, :inclusion => { :in => [true, false] }
end
