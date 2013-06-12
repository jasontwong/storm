class Client < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :active, :client_group_id, :company_id, :email, :name, :password, :salt

  has_one :company, inverse_of: :clients

  validates :email, email: true, presence: true, uniqueness: true
  validates :company_id, presence: true
  validates :password, presence: true
  validates :salt, presence: true
  validates :active, inclusion: { :in => [true, false] }

end
