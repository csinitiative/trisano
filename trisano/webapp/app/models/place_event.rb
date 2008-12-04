# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

class PlaceEvent < Event

  has_one :place, :class_name => 'Participation', 
    :foreign_key => "event_id", 
    :conditions => ["role_id = ?", Code.place_of_interest_type_id]

  validates_associated :place

  after_save :set_primary_entity_on_secondary_participations

  class << self
    # Only creates the events.  Does not save.
    def initialize_from_morbidity_event(morbidity_event)
      place_events = []
      morbidity_event.place_exposures.select(&:new_record?).each do |place_exposure|

        primary = Participation.new
        primary.primary_entity = place_exposure.secondary_entity
        primary.role_id = Event.participation_code('Place of Interest')
        primary.primary_entity.entity_type = "place"

        contact = Participation.new
        contact.secondary_entity = morbidity_event.active_patient.primary_entity
        contact.role_id = Event.participation_code('Contact')
        
        jurisdiction = Participation.new
        jurisdiction.secondary_entity = morbidity_event.active_jurisdiction.secondary_entity
        jurisdiction.role_id = Event.participation_code('Jurisdiction') 

        unless morbidity_event.disease.nil?
          disease_event = DiseaseEvent.new
          disease_event.disease = morbidity_event.disease.disease
        end

        place_event = PlaceEvent.new
        place_event.participations << primary
        place_event.participations << contact
        place_event.participations << jurisdiction
        place_event.disease_event = disease_event unless morbidity_event.disease.nil?

        # Link this place event to the originating morbidity event.
        place_event.parent_event = morbidity_event
        # Also link it to the participation.  DEBT: Undo this after the rush to 1.0.  It's kind of a hack.
        place_exposure.participating_event = place_event

        place_events << place_event
      end
      place_events
    end
  end
  
  def active_place
    self.place
  end

  def active_place=(attributes)
    self.place = Participation.new_exposure_participation if self.place.nil?
    self.place.primary_entity.attributes = attributes
  end
  
  def self.core_views
    [
      ["Place", "Place"]
    ]
  end
  
  def save_associations
    place.save(false)
    place.primary_entity.save(false)
    super
  end

  def set_primary_entity_on_secondary_participations
    reload
    self.participations.each do |participation|
      if participation.primary_entity_id.nil?
        participation.update_attribute('primary_entity_id', self.place.primary_entity.id)
      end
    end
  end
end
