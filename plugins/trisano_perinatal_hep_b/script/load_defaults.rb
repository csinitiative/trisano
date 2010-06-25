require 'yaml'

puts "Loading Perinatal Hep B core fields"

fields = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'db', 'defaults', 'core_fields.yml'))
CoreField.load!(fields.values)

puts "Loading Perinatal Hep B CSV fields"

csv_fields = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'misc', 'en_csv_fields.yml'))
CsvField.load_csv_fields(csv_fields)
