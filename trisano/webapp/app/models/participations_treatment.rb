class ParticipationsTreatment < ActiveRecord::Base
  belongs_to :participations
  belongs_to :treatment_given_yn, :class_name => 'ExternalCode'
end
