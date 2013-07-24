class Store < ActiveRecord::Base
  RECEIPT_TYPE_WENDYS_1 = 1
  attr_accessible :address1, :address2, :city, :company_id, :country, :latitude, :longitude, :name, :phone, :state, :zip

  belongs_to :company, inverse_of: :stores
  has_and_belongs_to_many :surveys
  has_many :codes, inverse_of: :store
  has_many :survey_questions, through: :surveys
  has_many :orders, inverse_of: :store
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

  def parse_receipt(text, order)
    data = {
      items: []
    }
    lines = text.split("\n")
    lines.delete_if { |line| /\d+\.\d{2}/.match(line).nil? }
    is_item = true

    case self.receipt_type
    when Store::RECEIPT_TYPE_WENDYS_1
      lines.keep_if do |line| 
        is_item = false if line.downcase.include? 'subtotal'
        is_item
      end
      lines.each do |line| 
        item = line.strip().split(/\s{2,}/)
        OrderDetail.create!(
          quantity: item[0][/^\d+\s/].strip().to_i,
          name: item[0].sub(/^\d+/, '').strip(),
          price: item[1][/\d+\.\d{2}/].to_f,
          order_id: order.id,
          code_id: order.code.id,
        )
      end
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
