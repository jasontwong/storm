class Store < ActiveRecord::Base
  RECEIPT_TYPE_WENDYS_1 = 1

  belongs_to :company, inverse_of: :stores
  belongs_to :store_group, inverse_of: :stores
  has_and_belongs_to_many :clients
  has_and_belongs_to_many :surveys
  has_many :codes, inverse_of: :store
  has_many :survey_questions, through: :surveys
  has_many :member_rewards, inverse_of: :store
  has_many :member_surveys, inverse_of: :store

  validates :address1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :company_id, presence: true
  validates :country, presence: true
  validates :name, presence: true
  validates :zip, presence: true
  validates :phone, presence: true

  before_create :make_full_address
  before_save :make_full_address

  def make_full_address
    location = self.address1
    if self.address2 && self.address2.length > 0
      location += ' ' + self.address2
    end

    location += ', ' + self.city
    location += ', ' + self.state
    if self.country.length > 0
      location += ', ' + self.country
    end
    location += ', ' + self.zip

    self.full_address = location
  end

  def parse_receipt(text, order)
    data = {
      items: []
    }
    lines = text.split("\n")
    lines.delete_if { |line| /\d+\.\d{2}/.match(line).nil? }
    is_item = true
    subtotal = 0

    case self.receipt_type
    when Store::RECEIPT_TYPE_WENDYS_1
      lines.keep_if do |line| 
        is_item = false if line.downcase.include? 'subtotal'
        is_item
      end
      lines.each do |line| 
        item = line.strip().split(/\s{2,}/)
        price = item[1][/\d+\.\d{2}/].to_f
        OrderDetail.create!(
          quantity: item[0][/^\d+\s/].strip().to_i,
          name: item[0].sub(/^\d+/, '').strip(),
          price: price,
          order_id: order.id,
          code_id: order.code.id,
        )
        subtotal += price
      end

      order.survey_worth = subtotal
      order.save
    else
      lines.keep_if do |line| 
        is_item = false if line.downcase.include? 'subtotal'
        is_item
      end

      lines.each do |line| 
        item = line.split(/\s{2,}/)
        data[:items] << {
          name: item[0],
          price: item[1][/\d+\.\d{2}/].to_f,
        }
      end

    end

  end

end
