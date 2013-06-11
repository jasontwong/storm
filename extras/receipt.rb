class Receipt < String
  def parse_data(cols = nil)
    data = {
      items: [],
    }

    lines = self.split("\n")
    lines.delete_if { |line| /\d+\.\d{2}/.match(line).nil? }
    is_item = true
    lines.keep_if do |line| 
      is_item = false if line.downcase.include? 'subtotal'
      is_item
    end

    case cols
    when 2
      lines.each do |line| 
        item = line.split(/\s{2,}/)
        data[:items] << {
          name: item[0],
          price: item[1][/\d+\.\d{2}/].to_f,
        }
      end
    when 3
      lines.each do |line| 
        item = line.split(/\s{2,}/)
        data[:items] << {
          name: item[0],
          price: item[2][/\d+\.\d{2}/].to_f,
        }
      end
    end

    return data
    
  end

end
