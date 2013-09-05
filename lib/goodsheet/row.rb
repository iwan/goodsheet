require 'active_model'

module Goodsheet
  
  class Row
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    class << self
      attr_accessor :keys
    end
    @keys = {} # idx => key

    def initialize(arr)
      arr.each_with_index do |v, idx|
        if k = self.class.keys[idx]
          send("#{k}=", v)       
        end
      end
      super()
    end

    def self.inherit(block)
      c = Class.new(self) do
        @keys = {} # idx => key
      end
      c.class_eval(&block)
      c
    end

    # Define the position (or index) and the name of columns.
    # There are available three mode to define them:
    # using an hash index to name (like { 0 => :year, 2 => :day }) 
    # or name to index (like { :year => 0, :day => 2 }) or using an array
    # with the names at desired positions (like [:year, nil, :day]), put a nil
    # at the position 
    # The positions are 0-based.
    def self.column_names(param)
      @keys = {}
      if param.is_a? Hash
        if param.first[0].is_a? Integer
          param.each do |idx, name|
            self.keys[idx] = name
            attr_accessor name
          end
        else
          param.each do |name, idx|
            self.keys[idx] = name
            attr_accessor name
          end
        end
      elsif param.is_a? Array
        param.each_with_index do |name, idx|
          if name
            self.keys[idx] = name
            attr_accessor name        
          end
        end

      else
        raise "parameter non valid"
      end
    end


    def persisted?
      false
    end

    # Get the list of attributes (the columns to import)
    def self.row_attributes
      @keys.values
    end
  end
end
