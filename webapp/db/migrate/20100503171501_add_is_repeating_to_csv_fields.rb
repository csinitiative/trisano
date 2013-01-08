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

class AddIsRepeatingToCsvFields < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :csv_fields, :collection, :string

      [["contact_event", "contact_hospital_admission_date"],
       ["contact_event", "contact_hospital_discharge_date"],
       ["contact_event", "contact_hospitalization_facility"],
       ["contact_event", "contact_hospital_medical_record_no"],
       ["morbidity_event", "patient_hospitalization_facility"],
       ["morbidity_event", "patient_hospital_admission_date"],
       ["morbidity_event", "patient_hospital_discharge_date"],
       ["morbidity_event", "patient_hospital_medical_record_no"]].each do |csv_field|

        field = CsvField.find_by_event_type_and_long_name(csv_field[0], csv_field[1])

        unless field.nil?
          first_position = field.use_description.index(".first")
          try_position = field.use_description.index(".try")

          values = {}
          values['collection'] = field.use_description[0..first_position-1]
          values['use_description'] = field.use_description[try_position+1...field.use_description.size]

          unless field.use_code.blank?
            new_use_code = field.use_code[try_position+1...field.use_code.size]
            values['use_code'] = new_use_code
          end

          execute(<<-SQL)
            UPDATE csv_fields
               SET #{values.map{|k,v| "#{k} = '#{v}'"}.join(", ")}
             WHERE id = #{field.id}
          SQL
        end
      end
    end
  end

  def self.down
    remove_column :csv_fields, :collection
  end
end
