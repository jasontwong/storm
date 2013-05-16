class Member < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :member_attributes

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
