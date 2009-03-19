class CsvField < ActiveRecord::Base
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
end
