class CsvField < ActiveRecord::Base
  default_scope :order => 'sort_order'
  named_scope :morbidity_event_fields, :conditions => { :event_type => 'morbidity_event' }
  named_scope :place_event_fields,     :conditions => { :event_type => 'place_event' }
  named_scope :contact_event_fields,   :conditions => { :event_type => 'contact_event' }
  named_scope :lab_fields,             :conditions => { :group      => 'lab' }
  named_scope :treatment_fields,       :conditions => { :group      => 'treatment' }

  validates_length_of :short_name, :allow_nil => true, :maximum => 10
end
