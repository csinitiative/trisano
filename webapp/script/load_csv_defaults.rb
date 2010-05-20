puts "Loading CSV configuration"

# CSV configuration
csv_fields = YAML::load_file("#{RAILS_ROOT}/../plugins/trisano_en/config/misc/csv_fields.yml")
CsvField.load_csv_fields(csv_fields)
