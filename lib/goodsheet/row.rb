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
    # You have four ways to define them: 
    # using an hash index-to-name (like { 0 => :year, 2 => :day }) 
    # or its reversed version name-to-index (like { :year => 0, :day => 2 }), using an array
    # with the names at desired positions (like [:year, nil, :day]), put a nil
    # at the position, or simply put the list of names.
    # The positions are 0-based.
    def self.column_names(*attr)
    # def self.column_names(param)
      @keys = {}
      raise ArgumentError, 'You have to pass at least one attribute' if attr.empty?
      if attr[0].is_a? Array
        attr[0].each_with_index do |name, idx|
          if name
            self.keys[idx] = name
            attr_accessor name        
          end
        end
        
      elsif attr[0].is_a? Hash
        if attr[0].first[0].is_a? Integer
          attr[0].each do |idx, name|
            self.keys[idx] = name
            attr_accessor name
          end
        else
          attr[0].each do |name, idx|
            self.keys[idx] = name
            attr_accessor name
          end
        end

      else
        attr.each_with_index do |name, idx|
          if name
            name = name.to_s.gsub(" ", "_").to_sym unless name.is_a? Symbol
            self.keys[idx] = name
            attr_accessor name        
          end
        end
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
