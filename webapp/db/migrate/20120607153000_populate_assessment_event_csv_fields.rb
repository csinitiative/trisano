class PopulateAssessmentEventCsvFields < ActiveRecord::Migration
  # We must collect the existing csv fields for morbidyt events and then duplicate them for 
  # assessment events
  def self.up
    assessment_csv_fields = CsvField.find(:all, :conditions => ["event_type = ?", "assessment_event"])
    
    # We only want to load assessment csv fields from morbidity csv fields
    # unless they've been defined.
    if assessment_csv_fields.empty?

      CsvField.transaction do
        csv_fields = YAML::load( File.open("#{RAILS_ROOT}/vendor/trisano/trisano_en/config/misc/en_csv_fields.yml") )
        csv_fields.each do |field_name, attributes|
          CsvField.load_csv_fields({field_name=>attributes}) if attributes['event_type'] == "assessment_event"
        end

        # Normally we would also want to load the geocode_csv_fields at this time, but because
        # trisano_ee monkeypatches CsvFields.load_csv_fields to do this automatically we don't need to
        # See webapp/vendor/trisano/trisano_ee/lib/trisano_ee/models/csv_field.rb 

        # Because we don't want to JUST load defaults, we'll also migrate everything from MorbidityEvents
        morbidity_csv_fields = CsvField.find(:all, :conditions => ["event_type = ?", "morbidity_event"])

        offset=10000
        counter=0

        morbidity_csv_fields.each do |field|
          new_field = csv_field_to_hash(field)
          new_field['event_type'].gsub!("morbidity", "assessment")
          new_field['sort_order'] += offset

          field_name = "csv_field_#{counter+offset}:\n"

          CsvField.load_csv_fields({field_name => new_field})
        end
      end
    
    else
      puts "Assessment csv fields already defined.  No action taken."
    end
  end

  def self.down
    CsvField.find(:all, :conditions => ["event_type = ?", "assessment_event"]).each do |csv_ae|
      csv_ae.csv_field_translations.each { |cft| cft.destroy }
      csv_ae.destroy
    end
  end

  def self.csv_field_to_hash(csv_field)
    hash = {}
    values = %w(sort_order export_group long_name use_description short_name use_code event_type collection)
    values.each do |value|
      hash[value.to_s] = csv_field.send(value.to_sym)
    end
    return hash
  end

end
