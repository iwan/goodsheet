module Spreadsheet

  class Workbook
    def sheets
      Array.new(sheet_count){|i| i}.collect{|e| worksheet(i).name}
    end

  end
end