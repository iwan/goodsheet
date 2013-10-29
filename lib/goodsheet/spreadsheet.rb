require 'roo'

module Goodsheet

  class Spreadsheet < Roo::Spreadsheet
    attr_reader :skip, :header_row, :max_errors, :row_limit
    attr_reader :s_opts, :ss

    # Initialize a Goodsheet object. The first sheet will be selected.
    #
    # @param filename [String] The spreadsheet filename you want to read
    # @param [Hash] options Options to define the behaviour on reading and validation the sheets. These options are applied to all sheets, but can be overwritten by similar options when selecting the sheet or calling +read+ or +validate+ method
    # @option options [Fixnum] :skip (1) Number of rows to skip
    # @option options [Fixnum] :header_row (0) The header row index (0-based)
    # @option options [Fixnum] :max_errors (0) Max number of error until stop validation
    # @option options [Fixnum] :row_limit (0) Max number of row to read
    # @option options [Object] :force_nil (nil) Force nils found to this value
    def initialize(filename, options={})
      # set_book_options(options)
      @filename = filename
      @ss = Roo::Spreadsheet.open(filename, options)
      @s_opts = Array.new(size, {})
      size.times do |i|
        set_sheet_options(i, options)
      end
    end
    

    # Select the desidered sheet.
    #
    # @param idx [Fixnum, String] The index (0-based) or the name of the sheet to select
    # @param [Hash] options Options to define the behaviour on reading and validation the sheet. These options are applied only to the current sheet, but can be overwritten by similar options when calling +read+ or +validate+ method
    # @option options [Fixnum] :skip (1) Number of rows to skip
    # @option options [Fixnum] :header_row (0) The header row index (0-based)
    # @option options [Fixnum] :max_errors (0) Max number of error until stop validation
    # @option options [Fixnum] :row_limit (0) Max number of row to read
    # @option options [Object] :force_nil (nil) Force nils found to this value
    def sheet(idx, options={})
      check_sheet_exists(idx)
      @ss.sheet(idx)
      set_sheet_options(idx, options)
    end

    # Get the sheet names list
    #
    # @return [Array<String>] An array with sheet names.
    def sheets
      @ss.sheets
    end

    # Get the number of sheets
    #
    # @return [Fixnum] Number of sheets.
    def size
      @ss.sheets.size
    end

    # Get the options of current sheet
    #
    # @return [Fixnum] Number of sheets.
    def options
      @s_opts[index]
    end


    # Get the header row of the currently selected sheet
    #
    # @return [Array<Object>] An array cell content objects (String, Float, ...)
    def get_header
      @ss.row(@s_opts[index][:header_row]+1) # because roo in 1-based
    end

    # Get the name of current (default) sheet
    #
    # @return [String] The sheet name
    def name
      @ss.default_sheet
    end

    # Get the index of current (default) sheet
    #
    # @return [Fixnum] The sheet index
    def index
      @ss.sheets.index(@ss.default_sheet)
    end

    # Get the total number of rows (of the currently selected sheet)
    #
    # @return [Fixnum] The number of rows
    def total_rows
      @ss.parse.size
    end

    # Get the number of all rows minus the skipped ones (of the currently selected sheet)
    #
    # @return [Fixnum] The number of rows
    def rows_wo_skipped
      @ss.parse.size - @s_opts[index][:skip]
    end
    alias :rows :rows_wo_skipped

    # Validate the current sheet.
    #
    # @param [Hash] options Validation options for the current sheet. 
    # @option options [Fixnum] :skip (1) Number of rows to skip
    # @option options [Fixnum] :header_row (0) The header row index (0-based)
    # @option options [Fixnum] :max_errors (0) Max number of error until stop validation
    # @option options [Fixnum] :row_limit (0) Max number of row to read
    # @option options [Object] :force_nil (nil) Force nils found to this value
    # @yield Column settings and validation rules
    # @return [ValidationErrors] Validation errors
    def validate(options={}, &block)
      set_variables(options)
      errors = ValidationErrors.new(@max_errors)
      row_class = Row.extend_with(block)

      last_row = @row_limit.zero? ? @ss.last_row : min(@ss.last_row, @row_limit+@skip)
      (@skip+1).upto(last_row) do |r|
        break unless errors.add(r, row_class.new(@ss.row(r), @force_nil))
      end
      errors
    end


    # Validate and, if successful, read the current sheet.
    #
    # @param [Hash] options Reading and validation options for the current sheet. 
    # @option options [Fixnum] :skip (1) Number of rows to skip
    # @option options [Fixnum] :header_row (0) The header row index (0-based)
    # @option options [Fixnum] :max_errors (0) Max number of error until stop validation
    # @option options [Fixnum] :row_limit (0) Max number of row to read
    # @option options [Object] :force_nil (nil) Force nils found to this value
    # @yield Column settings and validation rules
    # @return [ReadResult] The result
    def read(options={}, &block)
      set_variables(options)
      row_class = Row.extend_with(block)
      read_result = ReadResult.new(row_class.attributes, @max_errors, options[:collector]||:a_arr)

      last_row = @row_limit.zero? ? @ss.last_row : min(@ss.last_row, @row_limit+@skip)
      (@skip+1).upto(last_row) do |r|
        break unless read_result.add(r, row_class.new(@ss.row(r), @force_nil))
      end
      read_result
    end   


    private



    def set_variables(options)
      @skip = options[:skip] || @s_opts[index][:skip]
      @header_row = options[:header_row] || @s_opts[index][:header_row]
      @max_errors = options[:max_errors] || @s_opts[index][:max_errors]
      @row_limit = options[:row_limit] || @s_opts[index][:row_limit] || 0
      @force_nil = options[:force_nil] || @s_opts[index][:force_nil]
    end

    def select_sheet_options(idx)
      if idx.is_a? Integer
        @s_opts[idx]
      elsif idx.is_a? String
        @s_opts[@ss.sheets.index(idx)]
      end
    end

    def check_sheet_exists(idx)
      if idx.is_a? Integer
        raise Goodsheet::SheetNotFoundError if idx < 0 || idx > (size-1)
      elsif idx.is_a? String
        raise Goodsheet::SheetNotFoundError if !@ss.sheets.include?(idx)
      else
        raise ArgumentError, "idx must be an Integer or a String"
      end
    end


    def set_sheet_options(idx, options)
      i = idx.is_a?(Integer) ? idx : @ss.sheets.index(idx)
      @s_opts[i] = {
        :skip => options[:skip] || @s_opts[i][:skip] || 1,
        :header_row => options[:header_row] || @s_opts[i][:header_row] || 0,
        :max_errors => options[:max_errors] || @s_opts[i][:max_errors] || 0,
        :row_limit => options[:row_limit] || @s_opts[i][:row_limit] || 0,
        :force_nil => options[:force_nil] || @s_opts[i][:force_nil] || nil
      }
    end

    def min(a,b)
      a<b ? a : b
    end
  end
end

