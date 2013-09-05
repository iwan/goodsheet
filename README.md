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
res.values # => {:a => [1.0, 1.0, 1.4], :b => []}
```

By default:
* the first sheet is selected
* one line (the first) is skipped (i'm expeting that is the header line)

Pass your validation rules into the block passed to the read method, together with the column_names method that define the position (or index) and the name of the columns you want to read.

### Advanced usage

to do



Warning:
* integer numbers are converted to float numbers. Also don't pretend to obtain an integer in validation. This undesired behaviour depend on Roo gem
* if you import data from a CSV spreadsheet keep in mind that numbers are readed as strings




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
