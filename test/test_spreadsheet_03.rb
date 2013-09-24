# test_spreadsheet_03.rb

# ruby -I lib test/test_spreadsheet_03.rb

require 'test/unit'
require 'goodsheet'

class TestSpreadsheet_03 < Test::Unit::TestCase

  def setup
    filepath = File.dirname(__FILE__) + "/fixtures/ss_01.xls"
    @ss = Goodsheet::Spreadsheet.new(filepath)
  end

  def test_validation_with_nil_values
    @ss.sheet(4) # "Sheet5"
    result = @ss.validate do
      column_names 0 => :qty, 1 => :price, 2 => :tot
      validates :qty, :price, :tot, numericality: true
    end
    assert(!result.valid?)

    result = @ss.validate(:force_nil => 0.0) do
      column_names 0 => :qty, 1 => :price, 2 => :tot
      validates :qty, :price, :tot, numericality: true
    end
    assert(result.valid?)
  end

  def test_reading_with_nil_values
    @ss.sheet(4) # "Sheet5"
    result = @ss.read do
      column_names 0 => :qty, 1 => :price, 2 => :tot
      validates :qty, :price, :tot, numericality: true
    end
    assert(!result.valid?)

    result = @ss.read(:force_nil => 0.0) do
      column_names 0 => :qty, 1 => :price, 2 => :tot
      validates :qty, :price, :tot, numericality: true
    end
    assert(result.valid?)
  end 

end