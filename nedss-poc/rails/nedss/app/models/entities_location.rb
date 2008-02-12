class EntitiesLocation < ActiveRecord::Base
  acts_as_reportable
  belongs_to :location
  belongs_to :entity

  belongs_to  :entity_location_type, :class_name => 'Code'
  belongs_to  :primary_yn, :class_name => 'Code'

  validates_associated :location
end
