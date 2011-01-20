puts "Loading CSV configuration"

# CSV configuration
csv_fields = YAML::load_file("#{RAILS_ROOT}/vendor/trisano/trisano_en/config/misc/en_csv_fields.yml")
CsvField.load_csv_fields(csv_fields)
