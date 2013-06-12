class ClientGroup < ActiveRecord::Base
  attr_accessible :name

  has_many :clients, inverse_of: :client_group
  has_and_belongs_to_many :client_permissions

  validates :name, presence: true, uniqueness: true
end
