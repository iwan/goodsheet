module Goodsheet
  class ReadingSettings
    DEFAULT_SKIP = 1
    DEFAULT_HEADER_ROW = 0
    DEFAULT_MAX_ERRORS = 0
    DEFAULT_ROW_LIMIT = 0
    DEFAULT_FORCE_NIL = nil
    attr_reader :skip, :header_row, :max_errors, :row_limit, :force_nil

    def initialize(options={})
      @skip = options[:skip] || DEFAULT_SKIP
      @header_row = options[:header_row] || DEFAULT_HEADER_ROW
      @max_errors = options[:max_errors] || DEFAULT_MAX_ERRORS
      @row_limit = options[:row_limit] || DEFAULT_ROW_LIMIT
      @force_nil = options[:force_nil] || DEFAULT_FORCE_NIL
    end

    def last?(line)
      return false if @row_limit.zero?
      line >= @skip+@row_limit
    end

    def first_line
      @skip+1
    end

    def last_line(last_row)
      @row_limit.zero? ? last_row : min(last_row, @row_limit+@skip)
    end

    private
    def min(a,b)
      a<b ? a : b
    end
  end 
end
