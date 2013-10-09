class CodeScanLocation < ActiveRecord::Base
  attr_accessible :code_id, :latitude, :longitude, :member_id, :success

  validates :code_id, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  validates :member_id, presence: true
  validates :success, :inclusion => { :in => [true, false] }
end
