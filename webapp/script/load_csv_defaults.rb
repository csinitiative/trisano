puts "Loading CSV configuration"

# CSV configuration
csv_fields = YAML::load_file("#{RAILS_ROOT}/db/defaults/csv_fields.yml")
CsvField.transaction do
  csv_fields.each do |k, v|
    CsvField.create(v)
  end
end
