require 'roo'

module Goodsheet

  class Spreadsheet < Roo::Spreadsheet
    attr_reader :time_zone, :skip, :header_row, :max_errors, :row_limit

    # Valid options:
    #    :skip       : number of rows to skip (default: 1)
    #    :header_row : header's row index (0 based, default: 0)
    #    :time_zone  : time zone string
    def initialize(filename, options={})
      set_options(options)
      @filename = filename
      @ss = Roo::Spreadsheet.open(filename, options)
    end
    

    # idx can be a number or a string
    def sheet(idx, options={})
      set_options(options)
      @ss.sheet(idx)
      check_sheet_exists
    end

    def sheets
      @ss.sheets
    end


    def get_header
      @ss.row(@header_row+1) # because roo in 1-based
    end

    # Get the currently selected sheet's name
    def name
      @ss.default_sheet
    end

    def total_rows
      @ss.parse.size
    end

    def rows_wo_header
      @ss.parse.size - @skip
    end
    alias :rows :rows_wo_header

    # Valid options:
    #    :max_errors   : The validation will be stopped if the number of errors exceed max_errors (default: 0 or don't stop)
    #    :limit        : Max number of rows to validate (default: 0 or validate all rows)

    # 
    def validate(options={}, &block)
      skip = options[:skip] || @skip
      header_row = options[:header_row] || @header_row
      max_errors = options[:max_errors] || @max_errors
      row_limit = options[:row_limit] || @row_limit

      validation_errors = ValidationErrors.new

      my_class = options[:my_custom_row_class] || build_my_class(block)

      line = skip # 0-based, from the top
      @ss.parse[skip..-1].each do |row| # row is an array of elements
        validation_errors.add(line, my_class.new(row))
        break if max_errors>0 && validation_errors.size >= max_errors
        break if row_limit && row_limit>0 && line>=(row_limit+skip-1)
        line +=1
      end
      validation_errors
    end


    # Columns must be an hash: labe for values and the column index like {:price => 5}
    def read(options={}, &block)
      skip = options[:skip] || @skip
      header_row = options[:header_row] || @header_row
      max_errors = options[:max_errors] || @max_errors
      row_limit = options[:row_limit] || @row_limit
      force_nil = options[:force_nil]

      my_class = build_my_class(block)
      options[:my_custom_row_class] = my_class
      read_result = ReadResult.new(validate(options){ block })
      return read_result if read_result.invalid?
        
      line = skip # 0-based, from the top
      @ss.parse[skip..-1].each do |row| # row is an array of elements
        my_class.row_attributes.each do |attribute|
          read_result.add(attribute, my_class.new(row), force_nil)
        end
        break if row_limit && row_limit>0 && line>=(row_limit + skip - 1)
        line +=1
      end
      read_result
    end   


    private

    def build_my_class(block)
      Object.const_set get_custom_row_class_name, Row.inherit(block)
    end

    def check_sheet_exists
      begin
        @ss.cell(1,1)
      rescue ArgumentError => e
        raise Goodsheet::SheetNotFoundError
      rescue RangeError => e
        raise Goodsheet::SheetNotFoundError
      end
    end

    def get_custom_row_class_name
      "CustRow_#{(Time.now.to_f*(10**10)).to_i}"
    end

    def set_options(options)
      @time_zone = options.delete(:zone) || "Rome"
      @skip = options.delete(:skip) || 1
      @header_row = options.delete(:header_row) || 0
      @max_errors = options.delete(:max_errors) || 0
      @row_limit = options.delete(:row_limit) || 0      
    end
  end
end


