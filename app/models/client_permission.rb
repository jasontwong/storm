class ClientPermission < ActiveRecord::Base
  has_and_belongs_to_many :clients
  has_and_belongs_to_many :client_groups

  validates :name, presence: true, uniqueness: true
end
