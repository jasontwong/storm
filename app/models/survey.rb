class Survey < ActiveRecord::Base
  attr_accessible :store_id, :default, :description, :title

  belongs_to :store, inverse_of: :surveys
  has_and_belongs_to_many :stores
  has_and_belongs_to_many :survey_questions

  validates :store_id, presence: true
  validates :default, :inclusion => { :in => [true, false] }
  validates :title, presence: true

  after_initialize :init

  def init
    self.default = false if self.default.nil?
  end

end
