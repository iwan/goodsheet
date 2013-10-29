require 'test/unit'
require 'goodsheet'

class TestDefaults < Test::Unit::TestCase

  def setup
    filepath = File.dirname(__FILE__) + "/fixtures/for_defaults.xls"
    @ss = Goodsheet::Spreadsheet.new(filepath, :skip => 1)
  end



  def test_invalid
    res = @ss.read do
      column_names 0 => :name, 1 => :number
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.invalid?)

    res = @ss.read do
      column_names 0 => :name, 1 => :number
      column_defaults 0 => "UNKNOWN"
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.invalid?)

    res = @ss.read do
      column_names 0 => :name, 1 => :number
      column_defaults 1 => 0.0
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.invalid?)
  end



  def test_force_nil_vs_defaults
    res = @ss.read(:force_nil => 0.0) do
      column_names 0 => :name, 1 => :number
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.valid?)
    assert_equal(["Joshua Baney", "Libby Meiers", "Dean Murdoch", 0.0, "Esmeralda Erben"], res.values[:name])
    assert_equal([3.0, 2.0, 0.0, 8.0, 1.0], res.values[:number])

    res = @ss.read(:force_nil => "foo") do
      column_names 0 => :name, 1 => :number
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.invalid?)
    assert_equal(["Joshua Baney", "Libby Meiers", "Dean Murdoch", "foo", "Esmeralda Erben"], res.values[:name])
    assert_equal([3.0, 2.0, "foo", 8.0, 1.0], res.values[:number])


    res = @ss.read(:force_nil => 1.0) do
      column_names 0 => :name, 1 => :number
      column_defaults 0 => "UNKNOWN", 1 => 10.0
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.valid?)
    assert_equal(["Joshua Baney", "Libby Meiers", "Dean Murdoch", "UNKNOWN", "Esmeralda Erben"], res.values[:name])
    assert_equal([3.0, 2.0, 10.0, 8.0, 1.0], res.values[:number])
  end



  def test_values_correctness
    res = @ss.read do
      column_names 0 => :name, 1 => :number
      column_defaults 0 => "UNKNOWN", 1 => 0.0
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.valid?)
    assert_equal(["Joshua Baney", "Libby Meiers", "Dean Murdoch", "UNKNOWN", "Esmeralda Erben"], res.values[:name])
    assert_equal([3.0, 2.0, 0.0, 8.0, 1.0], res.values[:number])
  end



  def test_not_existing_column
    res = @ss.read do
      column_names 0 => :name, 1 => :number, 2 => :fake
      column_defaults 0 => "UNKNOWN", 1 => 0.0
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res.valid?)
    assert_equal([nil, nil, nil, nil, nil], res.values[:fake])

    res = @ss.read do
      column_names 0 => :name, 1 => :number, 2 => :fake
      column_defaults 0 => "UNKNOWN", 1 => 0.0
      validates :name, :presence => true
      validates :number, :numericality => true
      validates :fake, :presence => true
    end
    assert(res.invalid?)

    res1 = @ss.read do
      column_names 0 => :name, 1 => :number, 2 => :fake
      column_defaults 0 => "UNKNOWN", 1 => 0.0, 2 => "EMPTY"
      validates :name, :presence => true
      validates :number, :numericality => true
      validates :fake, :presence => true
    end
    assert(res1.valid?)
  end



  def test_column_defaults_formats
    res_1 = @ss.read do
      column_names :name, :number
      column_defaults ["UNKNOWN", 0.0]
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res_1.valid?)

    res_2 = @ss.read do
      column_names :name, :number
      column_defaults "UNKNOWN", 0.0
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res_2.valid?)
    assert_equal(res_1.values, res_2.values)

    res_3 = @ss.read do
      column_names 0 => :name, 1 => :number
      column_defaults 1 => 0.0, 0 => "UNKNOWN"
      validates :name, :presence => true
      validates :number, :numericality => true
    end
    assert(res_3.valid?)
    assert_equal(res_1.values, res_3.values)
  end


end