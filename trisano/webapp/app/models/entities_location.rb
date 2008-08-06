class EntitiesLocation < ActiveRecord::Base
  belongs_to :location
  belongs_to :entity

  belongs_to  :entity_location_type, :class_name => 'ExternalCode'
  belongs_to  :primary_yn, :class_name => 'ExternalCode'

  # Should validate that entity_location_type and primary_yn are legitimate codes
end
