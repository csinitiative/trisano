# Copyright (C) 2007, 2008, 2009 The Collaborative Software Foundation
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

# This migration must be run after the migration that turns events into morbidity events

class CreateContactEventsFromContacts < ActiveRecord::Migration

  def self.up

    if RAILS_ENV == "production"
      say "Production environment: Creating contact events."
      contact_code_id = Event.participation_code('Contact')
      events = MorbidityEvent.find(:all, :include => "contacts", :conditions => ["participations.role_id = ?", contact_code_id])
      transaction do
        events.each do |morbidity_event|
          morbidity_event.contacts.each do |contact|

            primary = Participation.new
            primary.primary_entity = contact.secondary_entity
            primary.role_id = Event.participation_code('Interested Party')

            contact = Participation.new
            contact.secondary_entity = morbidity_event.patient.primary_entity
            contact.role_id = Event.participation_code('Contact')

            jurisdiction = Participation.new
            jurisdiction.secondary_entity = morbidity_event.jurisdiction.secondary_entity
            jurisdiction.role_id = Event.participation_code('Jurisdiction') 

            unless morbidity_event.disease.nil?
              disease_event = DiseaseEvent.new
              disease_event.disease = morbidity_event.disease.disease
            end

            contact_event = ContactEvent.new
            contact_event.participations << primary
            contact_event.participations << contact
            contact_event.participations << jurisdiction
            contact_event.disease_events << disease_event unless morbidity_event.disease.nil?
            contact_event.save
          end
        end
      end
    else
      say "Development environment: Skipping data migration."
      true
    end
  end

  # Assumes that no "work" has been done between self.up and self.down
  def self.down
    if RAILS_ENV == "production"
      say "Production environment: Creating contact events."
      events = ContactEvent.find(:all)
      transaction do
        events.each do |event|
          event.participations.each { |participation| participation.destroy }
          event.disease_disease_events.each { |disease_event| disease_event.destroy }
          event.destroy
        end
      end
    else
      say "Development environment: Nothing to undo"
    end
  end

end

