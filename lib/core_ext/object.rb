# {{{ class Object
class Object
  # {{{ def blank?
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  # }}}
end

# }}}
