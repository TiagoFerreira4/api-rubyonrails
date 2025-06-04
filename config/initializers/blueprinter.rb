# config/initializers/blueprinter.rb
require 'blueprinter'

Blueprinter.configure do |config|
  # config.datetime_format = ->(datetime) { datetime.nil? ? nil : datetime.iso8601 }
  config.sort_fields_by = :definition # default is :name
end