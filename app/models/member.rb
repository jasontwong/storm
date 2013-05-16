class Member < ActiveRecord::Base
  include ActiveModel::Validations
  # attr_accessible :title, :body
  has_many :member_attributes

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
