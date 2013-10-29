require "goodsheet/version"
require "goodsheet/aux"

module Goodsheet
  autoload :Row,                'goodsheet/row'
  autoload :SheetNotFoundError, 'goodsheet/exceptions'
  autoload :ReadResult,         'goodsheet/read_result'
  autoload :Spreadsheet,        'goodsheet/spreadsheet'
  autoload :ValidationError,    'goodsheet/validation_error'
  autoload :ValidationErrors,   'goodsheet/validation_errors'
  autoload :Version,            'goodsheet/version'
end

