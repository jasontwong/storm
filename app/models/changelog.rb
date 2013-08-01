class Changelog < ActiveRecord::Base
  attr_accessible :meta, :model, :type, :model_id

  serialize :meta, Hash

  validate :model, presence: true
  validate :type, presence: true

  after_initialize :init

  def init
    self.meta = {}
  end

end
