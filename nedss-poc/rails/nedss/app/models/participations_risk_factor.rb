class ParticipationsRiskFactor < ActiveRecord::Base
  belongs_to :participations
  belongs_to :food_handler, :class_name => 'ExternalCode'
  belongs_to :healthcare_worker, :class_name => 'ExternalCode'
  belongs_to :group_living, :class_name => 'ExternalCode'
  belongs_to :day_care_association, :class_name => 'ExternalCode'
  belongs_to :pregnant, :class_name => 'ExternalCode'
end
