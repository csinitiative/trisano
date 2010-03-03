puts "Loading CSV configuration"

# CSV configuration
csv_fields = YAML::load_file("#{RAILS_ROOT}/db/defaults/csv_fields.yml")
CsvField.load_csv_fields(csv_fields)
