class ParticipationsTreatment < ActiveRecord::Base
  belongs_to :particpations
  belongs_to :treatment_given_yn, :class_name => 'Code'
end