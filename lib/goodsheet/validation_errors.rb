module Goodsheet

  class ValidationErrors
    attr_reader :array

    def initialize
      @array = []
    end

    def add(line_number, row)
      @array << ValidationError.new(line_number+1, row.errors) if row.invalid?
    end

    def empty?
      @array.empty?
    end

    def size
      @array.size
    end

    def to_s
      @array.to_s
    end
  end
end
