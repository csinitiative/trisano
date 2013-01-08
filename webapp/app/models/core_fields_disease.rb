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
class CoreFieldsDisease < ActiveRecord::Base
  belongs_to :disease
  belongs_to :core_field

  validates_presence_of :disease
  validates_presence_of :core_field
  validates_uniqueness_of :core_field_id, :scope => :disease_id

  class << self
    def create_associations(disease_name, fields)
      reset_column_information
      transaction do
        disease = Disease.find_by_disease_name(disease_name)
        fields.each do |field|
          core_field = CoreField.find_by_key(field['key'])
          attributes = Hash[:disease, disease,
                            :core_field, core_field,
                            :rendered, field['rendered'] || true,
                            :replaced, field['replaced'] || false]
          if core_fields_disease = self.find_by_disease_id_and_core_field_id(disease.id, core_field.id)
            core_fields_disease.update_attributes!(attributes)
          else
            create!(attributes)
          end
        end
      end
    end

    def delete_by_disease_ids(disease_ids)
      delete_all(['disease_id in (?)', disease_ids])
    end

    def copy_by_disease_ids(disease_id, target_disease_ids)
      sql = sanitize_sql_for_conditions([<<-SQL, target_disease_ids, disease_id])
        INSERT INTO core_fields_diseases
          SELECT nextval('core_fields_diseases_id_seq'),
                 a.core_field_id,
                 b.id as disease_id,
                 a.rendered,
                 NOW() as created_at,
                 NOW() as updated_at,
                 a.replaced
            FROM core_fields_diseases a
            JOIN (
              SELECT id from diseases WHERE id IN (?)
            ) b ON ? = a.disease_id
       SQL
      connection.execute sql
    end

  end
end
