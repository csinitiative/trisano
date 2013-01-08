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
class DiseaseSpecificTreatment < ActiveRecord::Base
  belongs_to :disease
  belongs_to :treatment

  validates_presence_of :disease_id
  validates_presence_of :treatment_id
  validates_uniqueness_of :treatment_id, :scope => :disease_id, :allow_blank => true

  class << self
    def delete_by_disease_ids(disease_ids)
      delete_all(['disease_id in (?)', disease_ids])
    end

    def copy_by_disease_ids(source_id, target_ids)
      sql = sanitize_sql_for_conditions([<<-SQL, target_ids, source_id])
        INSERT INTO disease_specific_treatments
             SELECT nextval('disease_specific_treatments_id_seq'),
                    b.id as disease_id,
                    treatment_id,
                    NOW() as created_at,
                    NOW() as updated_at
               FROM disease_specific_treatments a
               JOIN diseases b ON b.id IN (?)
              WHERE a.disease_id = ?
      SQL
      connection.execute sql
    end
  end
end
