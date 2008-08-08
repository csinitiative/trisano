class ContactEvent < Event

  class << self
    def initialize_from_morbidity_event(morbidity_event)
      contact_events = []
      morbidity_event.contacts.select(&:new_record?).each do |contact|

        primary = Participation.new
        primary.primary_entity = contact.secondary_entity
        primary.role_id = Event.participation_code('Interested Party')

        contact = Participation.new
        contact.secondary_entity = morbidity_event.active_patient.active_primary_entity
        contact.role_id = Event.participation_code('Contact')

        jurisdiction = Participation.new
        jurisdiction.secondary_entity = morbidity_event.active_jurisdiction.active_secondary_entity
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
        contact_events << contact_event
      end
      contact_events
    end
  end

end
