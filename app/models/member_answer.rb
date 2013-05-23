class MemberAnswer < ActiveRecord::Base
  attr_accessible :answer, :code_id, :completed, :completed_time, :member_id, :question

  belongs_to :member, inverse_of: :member_answers
  belongs_to :code, inverse_of: :member_answers

  validates :code_id, presence: true
  validates :completed, inclusion: [true, false]
  validates :member_id, presence: true
  validates :question, presence: true
end
