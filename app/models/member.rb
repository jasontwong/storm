class Member < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :email, :password, :active, :salt, :fb_username, :fb_password

  has_many :member_attributes, inverse_of: :member
  has_many :orders, inverse_of: :member
  has_many :member_points, inverse_of: :member
  has_many :member_answers, inverse_of: :member

  validates :email, :uniqueness => true, :presence => true, :email => true
  validates :active, :inclusion => { :in => [true, false] }

  # this will send messages to AWS SQS member queue
  def self.message(action, data)
    # validate data
    user = {
      action: action,
      user: data,
      time: Time.now.to_i,
    }
    sqs = AWS::SQS.new(:region => ENV['AWS_REGION'])
    queue = sqs.queues.create('member')
    msg = queue.send_message(user.to_json)
  end
end
