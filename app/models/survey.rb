class Survey < ActiveRecord::Base
  attr_accessible :company_id, :default, :description, :title

  belongs_to :company
  has_many :survey_questions

  validates :company_id, presence: true
  validates :default, :inclusion => { :in => [true, false] }
  validates :title, presence: true

  after_initialize :init

  def init
    self.default = false
  end
end
