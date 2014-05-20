# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'goodsheet/version'
require 'date'

Gem::Specification.new do |spec|
  spec.name          = "goodsheet"
  spec.version       = Goodsheet::VERSION
  spec.authors       = ["Iwan Buetti"]
  spec.email         = ["iwan.buetti@gmail.com"]
  spec.description   = "Little gem that take advantage of Roo gem and Rails ActiveModel validation methods to read and validate the content of a spreadsheet"
  spec.summary       = "Extract and validate data from a spreadsheet"
  spec.homepage      = "https://github.com/iwan/goodsheet"
  spec.license       = "MIT"
  spec.date          = Date.today.to_s
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.3.5"
  # spec.add_development_dependency "bundler", "~> 1.4"
  spec.add_development_dependency "rake"

  spec.add_dependency('minitest')
  spec.add_dependency('roo', '~> 1.13.2') # https://github.com/Empact/roo
  spec.add_dependency('spreadsheet', '~> 0.9.6') # https://github.com/zdavatz/spreadsheet
  spec.add_dependency('activemodel', '~> 3.2')
  spec.add_dependency('google_drive')
end
