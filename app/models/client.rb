class Client < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :active, :client_group_id, :company_id, :email, :name, :password, :salt

  belongs_to :company, inverse_of: :clients
  belongs_to :client_group, inverse_of: :clients
  has_and_belongs_to_many :client_permissions
  has_and_belongs_to_many :stores

  validates :email, email: true, presence: true, uniqueness: true
  validates :company_id, presence: true
  validates :password, presence: true
  validates :salt, presence: true
  validates :active, inclusion: { :in => [true, false] }

end
