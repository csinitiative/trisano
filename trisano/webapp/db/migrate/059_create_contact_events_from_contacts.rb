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

