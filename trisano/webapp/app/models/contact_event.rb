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

class ContactEvent < HumanEvent

  class << self
    # Only creates the events.  Does not save.
    def initialize_from_morbidity_event(morbidity_event)
      contact_events = []
      morbidity_event.contacts.select(&:new_record?).each do |contact_participation|

        primary = Participation.new
        primary.participations_contact = contact_participation.participations_contact
        primary.primary_entity = contact_participation.secondary_entity
        primary.role_id = Event.participation_code('Interested Party')
        primary.primary_entity.entity_type = "person"

        contact = Participation.new
        contact.secondary_entity = morbidity_event.active_patient.primary_entity
        contact.role_id = Event.participation_code('Contact')

        if morbidity_event.active_jurisdiction
          jurisdiction = Participation.new
          jurisdiction.secondary_entity = morbidity_event.active_jurisdiction.secondary_entity
          jurisdiction.role_id = Event.participation_code('Jurisdiction') 
        end

        unless morbidity_event.disease.nil?
          disease_event = DiseaseEvent.new
          disease_event.disease = morbidity_event.disease.disease
        end

        contact_event = ContactEvent.new
        contact_event.patient = primary
        contact_event.contacts << contact
        contact_event.jurisdiction = jurisdiction if morbidity_event.active_jurisdiction
        contact_event.disease_event = disease_event unless morbidity_event.disease.nil?
        contact_event.new_note_attributes = {:note => "Event created."}

        # Link this contact to the originating morbidity event.
        contact_event.parent_event = morbidity_event
        # Also link it to the participation.  DEBT: Undo this after the rush to 1.0.  It's kind of a hack.
        contact_participation.participating_event = contact_event

        contact_events << contact_event
      end
      contact_events
    end
  end
  
  def self.core_views
    [
      ["Demographics", "Demographics"], 
      ["Clinical", "Clinical"], 
      ["Laboratory", "Laboratory"], 
      ["Epidemiological", "Epidemiological"]
    ]
  end

  def save_associations
    super
  end

end
