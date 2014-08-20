class Changelog < ActiveRecord::Base
  serialize :meta, Hash

  validate :model, presence: true
  validate :model_action, presence: true

  after_initialize :init

  def init
    self.meta = {}
  end

end
