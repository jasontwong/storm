module Storm
  # {{{ class Error < StandardError
  class Error < StandardError
    attr_reader :code, :status
    # {{{ def initialize(status, code = nil)
    def initialize(status, code = nil)
      @status = status if status.is_a? Integer
      @code = code if code.is_a? Integer
    end

    # }}}
  end

  # }}}
end
