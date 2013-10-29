module Goodsheet

  class ValidationError
    
    def initialize(line, val_err)
      @line = line
      @val_err = val_err.full_messages.join(', ')
    end
    
    def to_s
      "Row #{@line} is not valid: #{@val_err}"
    end
  end
end