require 'spreadsheet'
require 'roo'

%w(
    version
    common
    aux
    reading_settings
    spreadsheet/worksheet
    spreadsheet/workbook
    roo/base
    row
    exceptions
    read_result
    spreadsheet
    validation_error
    validation_errors
  ).each { |file| require File.join(File.dirname(__FILE__), 'goodsheet', file) }


module Goodsheet
  # ...
end

