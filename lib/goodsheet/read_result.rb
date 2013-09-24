module Goodsheet
  
  class ReadResult
    attr_reader :vv, :errors

    def initialize(errors=ValidationErrors.new)
      @errors = errors
      @vv = {}
    end

    def valid?
      @errors.empty?
    end

    def invalid?
      !valid?
    end

    def add(attribute, row)
      attribute = attribute.to_sym
      (@vv[attribute] ||= []) << row.send(attribute)
    end

    def values(format=:columns)
      values_size = 0
      values_size = @vv.values.first.size if @vv.values.first

      case format
      when :columns
        @vv

      when :rows_array
        Array.new(values_size) do |i1|
          Array.new(@vv.size) do |i2|
            @vv[@vv.keys[i2]][i1]
          end
        end

      when :rows_hash
        Array.new(values_size) do |i1|
          hh = {}
          @vv.keys.each{|k| hh[k] = @vv[k][i1] }
          hh
        end
      end
    end
  end
end