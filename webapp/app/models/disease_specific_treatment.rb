class DiseaseSpecificTreatment < ActiveRecord::Base
  belongs_to :disease
  belongs_to :treatment

  validates_presence_of :disease_id
  validates_presence_of :treatment_id
  validates_uniqueness_of :treatment_id, :scope => :disease_id, :allow_blank => true
end
