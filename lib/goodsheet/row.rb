require 'active_model'

module Goodsheet
  
  class Row
    include ActiveModel::Validations

    class << self
      attr_accessor :keys, :defaults, :defaults_attributes
    end
    # @keys = {} # idx => key: {0=>:name, 1=>:quantity, 2=>:price, 3=>:total, 6=>:password}
    # @defaults = {} # name => default_value

    def initialize(arr, nil_value=nil)
      # puts "--- arr: #{arr.inspect}"
      if (diff=self.class.keys.size-arr.size)>0
        arr = arr + Array.new(diff, nil)
      end
      arr.each_with_index do |v, idx|
        if k = self.class.keys[idx]
          send "#{k}=", v || self.class.defaults[k] || nil_value     
        end
      end
      super()
    end

    def self.inherit(block)
      c = Class.new(self) do
        @keys = {} # idx => key: {0=>:name, 1=>:quantity, 2=>:price, 3=>:total, 6=>:password}
        @defaults = {} # name => default_value
        @defaults_attributes = nil # name => default_value
      end
      c.class_eval(&block)
      c
    end

    # using indexes: defaults 1 => 0.0, 2 => ""
    # using names:   defaults :qty => 0.0, :name => ""
    def self.column_defaults(*attr)
      raise ArgumentError, 'You have to pass at least one attribute' if attr.empty?
      if self.keys.empty?
        self.defaults_attributes = attr
      else
        self.defaults_attributes = nil
        self.set_defaults(attr)
      end
    end

    def self.set_defaults(attr)
      if attr[0].is_a? Array # column_defaults [0.0, nil, "Unknown"]
        # @defaults = Hash[attr[0].map.with_index{|v, i| [self.keys[i], v]}]
        @defaults = Hash[attr[0].map.with_index{|v, i| [self.keys[i], v]}]

      elsif attr[0].is_a? Hash # column_defaults 0 => 0.0, 1 => nil, 2 => "Unknown"
         # --or-- column_defaults :size => 0.0, :weight => nil, :name => "Unknown"

        # @defaults = Hash[attr[0].to_a.collect{|a| [(a[0].is_a?(Fixnum)) ? (self.keys[a[0]]) : a[0], a[1]]}]
        @defaults = Hash[attr[0].to_a.collect{|a| [(a[0].is_a?(Fixnum)) ? (self.keys[a[0]]) : a[0], a[1]]}]

      else # column_defaults 0.0, nil, "Unknown"
        # @defaults = Hash[attr.map.with_index{|v, i| [self.keys[i], v]}]
        @defaults = Hash[attr.map.with_index{|v, i| [self.keys[i], v]}]
      end
    end


    # Define the position (or index) and the name of columns.
    # You have four ways to define them: 
    # using an hash index-to-name (like { 0 => :year, 2 => :day }) 
    # or its reversed version name-to-index (like { :year => 0, :day => 2 }), using an array
    # with the names at desired positions (like [:year, nil, :day]), put a nil
    # at the position, or simply put the list of names.
    # The positions are 0-based.
    def self.column_names(*attr)
      @keys = {}
      raise ArgumentError, 'You have to pass at least one attribute' if attr.empty?
      if attr[0].is_a? Array
        attr[0].each_with_index do |name, idx|
          self.set_key_pair(idx, name) if name
        end
        
      elsif attr[0].is_a? Hash
        if attr[0].first[0].is_a? Integer
          attr[0].each do |idx, name|
            self.set_key_pair(idx, name)
          end
        else
          attr[0].each do |name, idx|
            self.set_key_pair(idx, name)
          end
        end

      else
        attr.each_with_index do |name, idx|
          if name
            name = name.to_s.gsub(" ", "_").to_sym unless name.is_a? Symbol
            self.set_key_pair(idx, name)
          end
        end
      end

      if !self.defaults_attributes.nil?
        self.set_defaults(self.defaults_attributes)
      end
    end


    def self.set_key_pair(idx, name)
      self.keys[idx] = name
      attr_accessor name        
    end


    # def persisted?
    #   false
    # end

    # Get the list of attributes (the columns to import)
    def Row.attributes
      @keys.values
    end

    def attributes
      self.class.attributes
    end

    def Row.extend_with(block)
      class_name = "CustRow_#{(Time.now.to_f*(10**10)).to_i}"
      Object.const_set class_name, Row.inherit(block)
    end

    def to_hash
      Hash[self.class.attributes.map{|a| [a, self.send(a)]}]
    end

    def to_a
      self.class.attributes.map{|a| self.send(a)}
    end
  end
end

# class Row01 < Goodsheet::Row
#   column_names :filename => 0, :size => 1
#   validates :size, :numericality => true
# end

# r = Row01.new(["pippo", "e"])
# p r.valid?
# puts r.class.attributes.inspect
# puts r.to_hash.inspect
# puts r.to_a.inspect
