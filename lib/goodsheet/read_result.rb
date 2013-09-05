module Goodsheet
  
  class ReadResult
    attr_reader :values

    def initialize(errors=ValidationErrors.new)
      @errors = errors
      @values = {}
    end

    def valid?
      @errors.empty?
    end

    def invalid?
      !valid?
    end

    def add(attribute, row, force_nil=nil)
      attribute = attribute.to_sym
      (@values[attribute] ||= []) << (row.send(attribute) || force_nil)
    end

    def errors
      @errors.array
    end
  end
end