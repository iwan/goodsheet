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

Given a spreadsheet:
![Spreadsheet](https://raw.github.com/iwan/goodsheet/master/img/img_01.png)

```ruby
ss = Goodsheet::Spreadsheet.new("example.xls")
res = ss.read do
  column_names :filename => 0, :size => 1, :created_at => 3, :updated_at => 4 # i want to ignore 'description' column
  column_defaults :filename => "UNKNOWN"
  validates :filename, :presence => true
  validates :size, :presence => true, :numericality => { :greater_than_or_equal_to => 0.0 }
  validate :order_of_dates

  def order_of_dates
    if created_at > updated_at
      errors.add(:updated_at, "cannot be before creation date")
    end
  end
end
```

If validation is successfull the spreadsheet will be readed and his content retrieved:
```ruby
res.valid? # => true
res.values # => {:filename=>["img_01.jpg", "img_17.jpg", "img_56.jpg"], :size=>[123854.0, 278333.0, 529639.0], :created_at=>[#<Date: 2013-03-03 ((2456355j,0s,0n),+0s,2299161j)>, ...], ...}
```

Alternatively you can get the result values by rows:
```ruby
res.values(:rows_array) # => [["img_01.jpg", 123854.0, #<Date: 2013-03-03 ((2456355j,0s,0n),+0s,2299161j)>, #<Date: 2013-03-31 ((2456383j,0s,0n),+0s,2299161j)>], ["img_17.jpg", 278333.0, #<Date: 2013-05-03 ...], ...]

res.values(:rows_hash) # => [{:filename=>"img_01.jpg", :size=>123854.0, :created_at=>#<Date: 2013-03-03 ((2456355j,0s,0n),+0s,2299161j)>, :updated_at=>#<Date: 2013-03-31 ((2456383j,0s,0n),+0s,2299161j)>}, {:filename=>"img_17.jpg", :size=>278333.0, ...}, ... ]
```

If validation fails the spreadsheet will not be readed:
```ruby
res.valid? # => false
res.errors.size # => 1
res.errors.to_a.first # => "Row 3 is invalid: Filename can't be blank"
res.values # => {}
```

By default:
* the first sheet is selected
* one line (the first) is skipped (i'm expeting that is the header line)

You can also invoke `validate` instead of `read` method (see below).
A validation will be always executed before the extraction (reading) of data. If validation fails the reading will not be performed.

The definition of columns you want to read (through the `column_names` method) and the rules for validation are defined inside the block you pass to `read` or `validate` method.



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

An hash of options can be passed to spreadsheet initializer `Goodsheet::Spreadsheet.new`, to `sheet` selection, to `validate` or `read` method. The first one define validation/reading rules for all sheets, but these can be overwritten by sheet and `validate`/`read`.

```ruby
ss = Goodsheet::Spreadsheet.new("my_data.xlsx", :skip => 1, :header_row => 0, :max_errors => 0, :row_limit => 0, :force_nil => nil )
```
These are the valid options with their default values:
- `:skip` allow to skip a desired number of lines when you read or validate a sheet (1)
- with `:header_row` you define the index of the header row (0)
- with `:max_errors` you define the maximum number of errors after the validation break (0: no limit)
- with `:row_limit` you define the maximum number of row you wanto to read or validate (0: no limit)
- with `:force_nil` you can specify the value to set when a cell hold a nil value (is empty) (still nil)

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

Use the `validate` and `read` methods to perform validation and reading. Note that the reading function include the validation step.
Pass the previously seen `options` hash and a block to `validate`/`read` method.
Inside the block you define columns names and indexes you want to validate/read using the `column_names` method. You can use one of these 4 forms (and their effect is identical):
- `column_names :a => 0, :b => 1, :c => 3`
- `column_names 0 => :a, 1 => :b, 3 => :c`
- `column_names [:a, :b, nil, :c]`
- `column_names :a, :b, nil, :c`

Use the `column_defaults` method to specify the value to set when the corresponding cell hold a nil value (is empty). Like the previous method, the following forms are identical:
- `column_defaults :a => 0.0, :b => 0.0, :c => "UNKNOWN"`
- `column_defaults 0 => 0.0, 1 => 0.0, 3 => "UNKNOWN"`
- `column_defaults [0.0, 0.0, "UNKNOWN"]`
- `column_defaults 0.0, 0.0, "UNKNOWN"`
The `column_defaults` macro overwrite the read/validate `:force_nil` option.

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
