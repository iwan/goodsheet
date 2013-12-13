module Spreadsheet

  class Worksheet
    include Goodsheet::Common

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
      row_class, read_result, errors = init(options, &block)

      each_with_index(@settings.skip) do |row, i|
        break if @settings.last?(i+@settings.skip) || !errors.add(i+@settings.skip, row_class.new(row, @settings.force_nil))
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
      row_class, read_result, errors = init(options, &block)
      
      each_with_index(@settings.skip) do |row, i|
        break if @settings.last?(i+@settings.skip) || !read_result.add(i+@settings.skip, row_class.new(row, @settings.force_nil))
      end
      read_result
    end


    def get_header(options={})
      settings = Goodsheet::ReadingSettings.new(options)
      row(settings.header_row).to_a
      # row(settings.header_row+1) # because roo in 1-based
    end

  end
end
