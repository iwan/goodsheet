module Goodsheet

  class ValidationError
    def initialize(line, val_err)
      @line = line
      @val_err = val_err
    end
    
    def to_s
      "Row #{@line} is invalid for the following reason(s): #{@val_err.full_messages.join(', ')}"
    end
  end
end