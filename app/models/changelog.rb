class Changelog < ActiveRecord::Base
  attr_accessible :meta, :model, :model_action, :model_id

  serialize :meta, Hash

  validate :model, presence: true
  validate :model_action, presence: true

  after_initialize :init

  def init
    self.meta = {}
  end

end
