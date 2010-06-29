require 'yaml'

puts "Loading Perinatal Hep B disease data"

disease_data = IO.read(File.join(File.dirname(__FILE__), '..', 'db', 'defaults', 'diseases.yml'))
Disease.load_from_yaml(disease_data)

puts "Loading Perinatal Hep B core fields"

fields = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'db', 'defaults', 'core_fields.yml'))
CoreField.load!(fields.values)

puts "Loading Perinatal Hep B CSV fields"

csv_fields = YAML::load_file(File.join(File.dirname(__FILE__), '..', 'config', 'misc', 'en_csv_fields.yml'))
CsvField.load_csv_fields(csv_fields)
