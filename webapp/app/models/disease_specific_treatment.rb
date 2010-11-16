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
