class ApiKey < ActiveRecord::Base
  attr_accessible :access_token
  
  before_validation :generate_access_token

  validates :access_token, uniqueness: true, presence: true

  private

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

end
