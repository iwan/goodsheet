require 'test/unit'
require 'goodsheet'

class TestRow < Test::Unit::TestCase

  def test_column_names
    assert_raise ArgumentError do
      Goodsheet::Row.column_names
    end
    assert_raise NameError do
      Goodsheet::Row.column_names(6)
    end

    Goodsheet::Row.column_names(:a, nil, :b, :c)
    assert_equal(Goodsheet::Row.keys, {0 => :a, 2 => :b, 3 => :c})

    Goodsheet::Row.column_names([:a, nil, :b, :c])
    assert_equal(Goodsheet::Row.keys, {0 => :a, 2 => :b, 3 => :c})

    Goodsheet::Row.column_names(:a => 0, :b => 2, :c => 3)
    assert_equal(Goodsheet::Row.keys, {0 => :a, 2 => :b, 3 => :c})

    Goodsheet::Row.column_names(0 => :a, 2 => :b, 3 => :c)
    assert_equal(Goodsheet::Row.keys, {0 => :a, 2 => :b, 3 => :c})
  end


end
