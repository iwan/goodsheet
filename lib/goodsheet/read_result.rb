module Goodsheet
  class ReadResult
    attr_reader :errors

    def initialize(row_attributes, max_errors, collector=:a_arr)
      @row_attributes = row_attributes
      case collector
      when :hash
        @hash = {}
      when :a_arr
        @a_arr = []
      when :h_arr
        @h_arr = []
      end
      @errors = ValidationErrors.new(max_errors)
    end


    def add(row_number, row)
      if defined? @hash
        row.to_hash.each_pair do |k, v|
          (@hash[k]||=[]) << v                  # @hash = {:a => ["dog, "cat", ...], :b => [3, 7, ...]}
        end
      end
      @a_arr << row.to_a if defined? @a_arr     # @a_arr = [["dog", 3], ["cat", 7], ...]
      @h_arr << row.to_hash if defined? @h_arr  # @h_arr = [{:a => "dog", :b => 3}, {:a => "cat", :b => 7}, ...]
      @errors.add(row_number, row)
    end

    def valid?
      @errors.empty?
    end

    def invalid?
      !valid?
    end

    def values(format=:columns)
      if defined? @hash
        return [] if @hash.empty?
        values_for_hash(format)

      elsif defined? @h_arr
        return [] if @h_arr.empty?
        values_for_h_arr(format)

      elsif defined? @a_arr # @a_arr = [["dog", 3], ["cat", 7], ...]
        return [] if @a_arr.empty?
        values_for_a_arr(format)
      end
    end  

    def values_for_hash(format)
      case format
      when :columns
        @hash

      when :rows_array
        a1 = []
        @hash.values.first.size.times do |i|
          a1 << @row_attributes.collect{|a| @hash[a][i]}
        end
        a1

      when :rows_hash
        a1 = []
        @hash.values.first.size.times do |i|
          a2 = {}
          @row_attributes.each{|a| a2[a] = @hash[a][i]}
          a1 << a2
        end
        a1
      end
    end

    def values_for_a_arr(format)
      case format
      when :columns
        h = {}
        @row_attributes.each_with_index do |attrib, i|
          h[attrib] = @a_arr.map{|e| e[i]}
        end
        h

      when :rows_array
        @a_arr

      when :rows_hash
        @a_arr.map do |arr|
          Hash[@row_attributes.map.with_index{|attrib,i| [attrib, arr[i]]}]
        end
      end
    end

    def values_for_h_arr(format)
      case format
      when :columns
        keys = @h_arr.first.keys
        h = {}
        @h_arr.each do |e|
          keys.each do |key|
            (h[key] ||= []) << e[key] 
          end
        end
        h

      when :rows_array
        @h_arr.map(&:values)

      when :rows_hash
        @h_arr
      end
    end
  end
end