class CoreFieldsDisease < ActiveRecord::Base
  belongs_to :disease
  belongs_to :core_field

  validates_presence_of :disease
  validates_presence_of :core_field
  validates_uniqueness_of :core_field_id, :scope => :disease_id

  class << self
    def create_associations(disease_name, fields)
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
