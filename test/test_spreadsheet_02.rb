require 'test/unit'
require 'goodsheet'

class TestSpreadsheet_02 < Test::Unit::TestCase

  def get_filepath(filename)
    File.dirname(__FILE__) + "/fixtures/#{filename}"
  end

  def test_xls_validation
    validate(get_filepath("ss_02.xls"))
  end

  def test_xls_reading
    read(get_filepath("ss_02.xls"))
  end

  def test_xlsx_validation
    validate(get_filepath("ss_02.xlsx"))
  end

  def test_xlsx_reading
    read(get_filepath("ss_02.xlsx"))
  end

  # in CSV files all numbers are converted to strings, so the validation will not pass...
  # def test_csv_validation
  #   validate(get_filepath("ss_02.csv"))
  # end

  # def test_csv_reading
  #   read(get_filepath("ss_02.csv"))
  # end

  # parsing of '.ods' file is very slow for "large" files  (a spredsheet with 366 lines take 65'' to be parsing on my computer...)
  # def test_ods_validation
  #   validate(get_filepath("ss_02.ods"))
  # end

  # parsing of '.ods' file is very slow for "large" files  (a spredsheet with 366 lines take 65'' to be parsing on my computer...)
  # def test_ods_reading
  #   read(get_filepath("ss_02.ods"))
  # end

  # def test_google_ss_validation
  #   validate("0Ao3aUE9UFTaPdHBsYVhpU1FCaEVKMndkN1AzOVFYUUE")
  # end

  # def test_google_ss_reading
  #   read("0Ao3aUE9UFTaPdHBsYVhpU1FCaEVKMndkN1AzOVFYUUE")
  # end


  def validate(filepath)
    ss = Goodsheet::Spreadsheet.new(filepath)
    ss.sheet(0)
    errors = ss.validate(:skip => 1) do
      column_names 0 => :year, 1 => :month, 2 => :day, 3 => :wday, 4 => :num, 5 => :v
      validates :year, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 2000, :less_than_or_equal_to => 2020 }
      validates :month, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
      validates :day, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 31 }
      validates :wday, inclusion: { in:  %w(Mon Tue Wed Thu Fri Sat Sun) }
      validates :num, inclusion: { in:  [1, 2, 3] }
      validates :v, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100.0 }
    end

    assert_equal(0, errors.size)  
  end

  def read(filepath)
    ss = Goodsheet::Spreadsheet.new(filepath)
    ss.sheet(0)
    result = ss.read(:skip => 1) do
      column_names 0 => :year, 1 => :month, 2 => :day, 3 => :wday, 4 => :num, 5 => :v
      validates :year, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 2000, :less_than_or_equal_to => 2020 }
      validates :month, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
      validates :day, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 31 }
      validates :wday, inclusion: { in:  %w(Mon Tue Wed Thu Fri Sat Sun) }
      validates :num, inclusion: { in:  [1, 2, 3] }
      validates :v, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100.0 }
    end

    assert_equal(0, result.errors.size) 
    assert_equal(6, result.values.size)
    result.values.each do |k, v|
      assert_equal(365, v.size)
    end

    result.values[:year].each do |y|
      assert_equal(2013, y) # y is 2013.0
    end
    result.values[:month].each do |v|
      assert(v.between?(1,12))
    end
    result.values[:day].each do |v|
      assert(v.between?(1,31))
    end
    wdays = %w(Mon Tue Wed Thu Fri Sat Sun)
    result.values[:wday].each do |v|
      assert wdays.include? v
    end
    result.values[:num].each do |v|
      assert [1,2,3].include? v
    end
    result.values[:v].each do |v|
      assert(v.between?(0, 100.0))
    end
  end


end
