class ParticipationsRiskFactor < ActiveRecord::Base
  belongs_to :participations
  belongs_to :food_handler, :class_name => 'Code'
  belongs_to :healthcare_worker, :class_name => 'Code'
  belongs_to :group_living, :class_name => 'Code'
  belongs_to :day_care_association, :class_name => 'Code'
  belongs_to :pregnant, :class_name => 'Code'
end
