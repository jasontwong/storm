# {{{ class String
class String
  # {{{ def numeric?
  def numeric?
    true if Float(self) rescue false
  end

  # }}}
end

# }}}
