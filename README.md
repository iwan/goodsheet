# Goodsheet

Read and validate the content of a spreadsheet.
The gem take advantage of wonderful validation methods available in Rails ActiveModel library and the methods of Roo gem to read and validate a spreadsheet.
Refer to the [official guide](http://guides.rubyonrails.org/active_record_validations.html) for the validation rules.
Thanks to [Roo gem](https://github.com/Empact/roo) Goodsheet can handle OpenOffice, LibreOffice, Excel (both '.xls' and '.xlsx') and Google spreadsheets.


## Installation

Add this line to your application's Gemfile:

    gem 'goodsheet'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install goodsheet

## Usage

### Getting started

```ruby
ss = Goodsheet::Spreadsheet.new("my_data.xlsx")
res = ss.read do
  column_names :a => 0, :b => 1
  validates :a, :presence => true, :numericality => { :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 10 }
  validates :b, :presence => true, :numericality => { :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 100 }
end

res.valid? # => true
res.values # => {:a => [1.0, 1.0, 1.4], :b => [0.0, 3.7, 10.9]}
```

By default:
* the first sheet is selected
* one line (the first) is skipped (i'm expeting that is the header line)
* the content is returned as an hash of columns

Pass your validation rules into the block passed to the read method, together with the column_names method that define the position (or index) and the name of the columns you want to read.

### More on usage

You can select the desired sheet by index (starting from zero) or by name:
```ruby
ss = Goodsheet::Spreadsheet.new("my_data.xlsx")
ss.sheet(2) # select the third sheet
ss.sheet("Sheet4") # select the sheet named "Sheet4"
```

Get the number of sheets, and their names:
```ruby
ss.size # => 4
ss.sheets # => ["Sheet1", "Sheet2", "Sheet3", "Sheet4"]
```

When you init a new spreadsheet, you select a sheet or you invoke `validate` or `read` method, you can pass an hash of options.
```ruby
ss = Goodsheet::Spreadsheet.new("my_data.xlsx", :skip => 1, :header_row => 0, :max_errors => 0, :row_limit => 0, :force_nil => nil )
```
These are the valid options with their default values:
- `:skip` allow to skip a desired number of lines when you read or validate a sheet 
- with `:header_row` you define the index of the header row
- with `:max_errors` you define the maximum number of errors after the validation break
- with `:row_limit` you define the maximum number of row you wanto to read or validate
- with `:force_nil` you can specify the value to set when a cell hold a nil value (is empty)

As said you can use the same option when selecting a sheet
```ruby
ss.sheet(0, :skip => 2)
```
or read or validate a sheet:
```ruby
ss.validate(0, :force_nil => 0.0) do
  # ...
end
```

Get the content of header row:
```ruby
ss.get_header # => ["year", "month", "day"]
```

Get the number of rows:
```ruby
ss.total_rows # => all instanced rows
ss.rows_wo_skipped # => except the skipped ones, aliased by `rows` method
```

#### Reading and validate

Use the `validate` and `read` methods to perform validation and reading. Note that the reading function include a validation call.
Pass the previously seen `options` hash and a block to `validate`/`read` method.
Inside the block you define columns names and indexes you want to validate/read using the `column_names` method. You can use one of these 4 forms:
- `column_names :a => 0, :b => 1, :c => 3`
- `column_names 0 => :a, 1 => :b, 3 => :c`
- `column_names [:a, :b, nil, :c]`
- `column_names :a, :b, nil, :c`

Aside from define the columns settings, into block you define the validation rules. 
Refer to the [official guide](http://guides.rubyonrails.org/active_record_validations.html) and [ROR Api](http://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html)


Here another example:
```ruby
ss = Goodsheet::Spreadsheet.new("my_data.xlsx")
ss.sheet(1, :max_errors => 50, :force_nil => 0.0)
res = ss.read do
  column_names :item => 0, :qty => 1, :price => 2, :prod => 3
  # same as: [:item, :qty, :price, :prod]
  validates :item, :presence => true
  validates :qty, :presence => true, :numericality => { :greater_than => 0.0}
  validates :price, :presence => true, :numericality => { :greater_than => 0.0}
  validate :product

  def :product
    if qty * price != prod
      errors.add(:prod, "must be the product of qty and price")
    end
  end
end

res.valid?
```

If validation fails you get `false` on `res.valid?` call, and you retrieve an array with errors by calling `errors` method on result object:
If validation fails you can retrieve the errors array by calling `errors` method on result object:

```ruby
res.valid? # => false
res.invalid? # => true
res.errors # => a ValidationErrors object
res.errors.size # => 1
res.errors[0].to_s # => "Row 5 is invalid for the following reason(s): Year is not a number, Month is not a number"
```

If the validation ends successfully without errors, the result values are available using one of these three forms:
- hash of columns (default)
- array of rows, where the rows are array
- array of rows, where the rows are hashes


```
+------+-------+
| year | month |
+------+-------+
| 2012 |    1  |
+------+-------+
| 2012 |    2  |
+------+-------+
| 2012 |    3  |
+------+-------+
```

```ruby
res.values # => { :year => [2012, 2012, 2012], :month => [1, 2, 3]}
res.values(:columns) # same as the previous 
res.values(:rows_array) # => [[2012, 1], [2012, 2], [2012, 3]]
res.values(:rows_hash) # => [{:year => 2012, :month => 1}, {:year => 2012, :month => 2}, {:year => 2012, :month => 3}]
```



Note:
* integer numbers are converted to float numbers. Also don't pretend to obtain an integer in validation. This undesired behaviour depend on Roo gem
* if you import data from a CSV spreadsheet keep in mind that numbers are readed as strings




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
