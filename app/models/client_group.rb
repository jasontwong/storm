class ClientGroup < ActiveRecord::Base
  attr_accessible :name

  has_many :clients, inverse_of: :client_group

  validates :name, presence: true, uniqueness: true
end
