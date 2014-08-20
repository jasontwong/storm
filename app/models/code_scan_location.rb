class CodeScanLocation < ActiveRecord::Base
  validates :code_id, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :member_id, presence: true
  validates :success, :inclusion => { :in => [true, false] }
end
