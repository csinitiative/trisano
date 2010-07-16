class CsvField < ActiveRecord::Base
  belongs_to :core_field

  default_scope :order => 'sort_order'

  named_scope :morbidity_event_fields, :conditions => { :event_type => 'morbidity_event' }
  named_scope :morbidity_event_code_fields,
              :conditions => "event_type = 'morbidity_event' and use_code is not null"

  named_scope :place_event_fields, :conditions => { :event_type => 'place_event' }
  named_scope :place_event_code_fields,
              :conditions => "event_type = 'place_event' and use_code is not null"

  named_scope :contact_event_fields, :conditions => { :event_type => 'contact_event' }
  named_scope :contact_event_code_fields,
              :conditions => "event_type = 'contact_event' and use_code is not null"

  named_scope :lab_fields, :conditions => { :export_group => 'lab' }
  named_scope :lab_code_fields,
              :conditions => "export_group = 'lab' and use_code is not null"

  named_scope :treatment_fields, :conditions => { :export_group => 'treatment' }
  named_scope :treatment_code_fields,
              :conditions => "export_group = 'treatment' and use_code is not null"

  validates_length_of :short_name, :allow_nil => true, :maximum => 10

  def self.load_csv_fields(csv_fields)
    transaction do
      attributes = CsvField.new.attribute_names
      csv_fields.each do |k, v|
        v.delete_if { |key, value| !attributes.include?(key) } # Remove any extra attributes in the YAML that are not attributes on the model
        csv_field = CsvField.find_or_initialize_by_long_name(v)
        csv_field.save!
      end
    end
  end
end
