class Client < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :company, inverse_of: :clients
  has_and_belongs_to_many :stores

  validates :email, email: true, presence: true, uniqueness: true
  validates :company_id, presence: true
  validates :password, presence: true
  validates :salt, presence: true
  validates :active, inclusion: { :in => [true, false] }

end
