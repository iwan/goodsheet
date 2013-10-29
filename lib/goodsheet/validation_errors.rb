module Goodsheet

  class ValidationErrors < Array

    def initialize(limit=0)
      @max_size = (limit==0 || limit.nil?) ? Float::INFINITY : limit
    end

    # Add a potential error (will be added only if the row is not valid)
    #
    # @param line_number [Fixnum] Line number (0-based). 
    # @return [boolean] Return false if the limit has been reached, true otherwise.
    def add(line_number, row)
      self << ValidationError.new(line_number+1, row.errors) if row.invalid?
      self.size < @max_size
    end

    def valid?
      empty?
    end
  end
end
