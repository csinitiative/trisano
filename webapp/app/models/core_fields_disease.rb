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
                            :rendered, field['rendered'] || true]
          if core_fields_disease = self.find_by_disease_id_and_core_field_id(disease.id, core_field.id)
            core_fields_disease.update_attributes!(attributes)
          else
            create!(attributes)
          end
        end
      end
    end
  end
end
