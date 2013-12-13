require 'test/unit'
require 'goodsheet'

class TestFormats < Test::Unit::TestCase

  def setup
    @rules = proc do
      column_names 0 => :year, 1 => :month, 2 => :day, 3 => :wday, 4 => :num, 5 => :v
      validates :year, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 2000, :less_than_or_equal_to => 2020 }
      validates :month, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 12 }
      validates :day, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => 31 }
      validates :wday, inclusion: { in:  %w(Mon Tue Wed Thu Fri Sat Sun) }
      validates :num, inclusion: { in:  [1, 2, 3] }
      validates :v, :allow_nil => false, :numericality => { :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100.0 }
    end
    @rules_for_cvs = proc do
      column_names 0 => :year, 1 => :month, 2 => :day, 3 => :wday, 4 => :num, 5 => :v
      validates :year, :allow_nil => false
      validates :month, :allow_nil => false
      validates :day, :allow_nil => false
      validates :wday, inclusion: { in:  %w(Mon Tue Wed Thu Fri Sat Sun) }
      validates :num, inclusion: { in:  %w(1 2 3) }
      validates :v, :allow_nil => false
    end
    @options = {:skip => 1}
  end

  def get_filepath(filename)
    File.dirname(__FILE__) + "/fixtures/#{filename}"
  end


  # ==============================================


  # Test use of Spreadsheet gem
  def test_validation_for_spreadsheet_format
    ss = Spreadsheet.open(get_filepath("ss_02.xls"))
    sheet = ss.worksheet(0)
    errors = sheet.validate(@options, &@rules) 
    assert_equal(0, errors.size)
  end

  # Test use of Spreadsheet gem
  def test_reading_for_spreadsheet_format
    ss = Spreadsheet.open(get_filepath("ss_02.xls"))
    sheet = ss.worksheet(0)
    r(sheet)
  end


  # Test use of Roo gem
  def test_validation_for_roo_format_xls
    ss = Roo::Spreadsheet.open(get_filepath("ss_02.xls"))
    ss.sheet(0)
    errors = ss.validate(@options, &@rules) 
    assert_equal(0, errors.size)
  end

  # Test use of Roo gem
  def test_reading_for_roo_format_xls
    ss = Roo::Spreadsheet.open(get_filepath("ss_02.xls"))
    ss.sheet(0)
    r(ss)
  end

  # Test use of Roo gem
  # with cvs format all numbers are readed as string values
  def test_validation_for_roo_format_csv
    ss = Roo::Spreadsheet.open(get_filepath("ss_02.csv"))
    ss.sheet(0)
    errors = ss.validate(@options, &@rules_for_cvs) 
    assert_equal(0, errors.size)
  end

  # Test use of Roo gem
  # with cvs format all numbers are readed as string values
  def test_reading_for_roo_format_csv
    ss = Roo::Spreadsheet.open(get_filepath("ss_02.csv"))
    ss.sheet(0)
    result = ss.read(@options, &@rules_for_cvs)
    assert_equal(0, result.errors.size) 
    assert_equal(6, result.values.size)
    result.values.each do |k, v|
      assert_equal(365, v.size)
    end

    result.values[:year].each do |y|
      assert_equal(2013, y.to_i) # y is 2013.0
    end
    result.values[:month].each do |v|
      assert(v.to_i.between?(1,12))
    end
    result.values[:day].each do |v|
      assert(v.to_i.between?(1,31))
    end
    wdays = %w(Mon Tue Wed Thu Fri Sat Sun)
    result.values[:wday].each do |v|
      assert wdays.include? v
    end
    result.values[:num].each do |v|
      assert %w(1 2 3).include? v
    end
    result.values[:v].each do |v|
      assert(v.to_i.between?(0, 100.0))
    end  end

  # ==============================================


  def r(sheet)
    result = sheet.read(@options, &@rules)
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



  def validate(filepath)
    ss = Goodsheet::Spreadsheet.new(filepath)
    ss.sheet(0)
    errors = ss.validate(@options) do
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

end