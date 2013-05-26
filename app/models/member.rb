class Member < ActiveRecord::Base
  include ActiveModel::Validations
  attr_accessible :email, :password, :active, :salt, :fb_username, :fb_password, :other_id

  has_many :member_attributes, inverse_of: :member
  has_many :orders, inverse_of: :member
  has_many :member_points, inverse_of: :member, class_name: 'MemberPoints'
  has_many :member_answers, inverse_of: :member
  has_many :member_rewards, inverse_of: :member

  validates :email, :uniqueness => true, :email => true
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

    attrs.each { |name, val| self.member_attributes.build({ name: name, value: val }) }
  end
end
