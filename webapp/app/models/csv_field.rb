# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the
# terms of the GNU Affero General Public License as published by the
# Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class CsvField < ActiveRecord::Base
  belongs_to :core_field

  default_scope :order => 'sort_order'

  named_scope :assessment_event_fields, :conditions => { :event_type => 'assessment_event' }
  named_scope :assessment_event_code_fields,
              :conditions => "event_type = 'assessment_event' and use_code is not null"

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

  named_scope :hospitalization_facility_fields, :conditions => { :export_group => 'hospitalization_facility' }
  named_scope :hospitalization_facility_code_fields,
              :conditions => "export_group = 'hospitalization_facility' and use_code is not null"

  validates_length_of :short_name, :allow_nil => true, :maximum => 10

  def self.load_csv_fields(csv_fields)
    transaction do
      valid_attributes = CsvField.new.attribute_names
      csv_fields.each do |csv_field_label, csv_field_attributes|
        csv_field_attributes.delete_if { |attribute, value| !valid_attributes.include?(attribute) } # Remove any extra attributes in the YAML that are not attributes on the model
        csv_field = CsvField.find_or_initialize_by_long_name_and_event_type(csv_field_attributes)
        csv_field.save!
      end
    end
  end
end
