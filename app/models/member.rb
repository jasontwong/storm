class Member < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :email, :password, :active, :salt, :fb_username, :fb_password, :other_id

  has_many :member_attributes, inverse_of: :member
  has_many :orders, inverse_of: :member
  has_many :member_points, inverse_of: :member, class_name: 'MemberPoints'
  has_many :member_answers, inverse_of: :member
  has_many :member_rewards, inverse_of: :member

  validates :email, :email => true
  validates :active, :inclusion => { :in => [true, false] }

  def parse_attrs(attrs)
    unless self.member_attributes.nil?
      self.member_attributes.each do |attr|
        key = attr.name.to_sym
        val = data[key]
        unless val.nil?
          attr.value = val
          data.delete(key)
        end
      end
    end

    attrs.each { |name, val| MemberAttribute.new({ name: name, value: val, member_id: self.id }).save }
  end

  def parse_answers(answers)
    answers.each do |answer|
      member_answer = MemberAnswer.where(member_id: self.id, code_id: answer[:code_id], question: answer[:question]).last
      if member_answer.nil?
        member_answer = MemberAnswer.new(answer)
        member_answer.member = self
        member_answer.save
      else
        member_answer.update_attributes(answer)
      end
    end
  end
end
