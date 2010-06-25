class CoreFieldsDisease < ActiveRecord::Base
  belongs_to :disease
  belongs_to :core_field

  validates_presence_of :disease
  validates_presence_of :core_field

  class << self
    def create_associations(disease_name, fields)
      transaction do
        disease = Disease.find_by_disease_name(disease_name)
        fields.each do |field|
          core_field = CoreField.find_by_key(field['key'])
          create!(:disease => disease,
                  :core_field => core_field,
                  :rendered => field['rendered'] || true)
        end
      end
    end
  end
end
