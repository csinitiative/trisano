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

class MorbidityEvent < HumanEvent
  
#    def self.new_event_tree(event_hash = {:disease => {}, :active_jurisdiction => {}})
#      event = MorbidityEvent.new(event_hash)

    def self.new_event_tree
      event = MorbidityEvent.new

      event.patient = Participation.new_patient_participation_with_address_and_phone
      event.jurisdiction = Participation.new(:role_id => Event.participation_code('Jurisdiction'))
      event.build_disease_event
      event.patient.participations_treatments.build
      event.patient.build_participations_risk_factor
      event.labs << Participation.new_lab_participation
      event.hospitalized_health_facilities << Participation.new_hospital_participation
      event.diagnosing_health_facilities << Participation.new_diagnostic_participation
      event.contacts << Participation.new_contact_participation
      event.clinicians << Participation.new_clinician_participation
      event.reporting_agency = Participation.new_reporting_agency_participation
      event.reporter = Participation.new_reporter_participation
      event.notes.build
      event
    end
  
  # A hash that provides a basic field index for the event forms. It maps the event form
  # attribute keys to some metadata that is used to drive core field and core follow-up
  # configurations in form builder.
  # 
  # Names do not have to match the field name on the form views. Names are used to 
  # drive the drop downs for core field and core follow up configurations. So more context
  # can be given to these names than might appear on the actual event forms, because in
  # drop down in form builder, 'Last name' isn't going to be enough information for the user.
  def self.exposed_attributes
    {
      "morbidity_event[active_patient][active_primary_entity][person][last_name]" => {:type => :single_line_text, :name => "Patient last name", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][first_name]" => {:type => :single_line_text, :name => "Patient first name", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][middle_name]" => {:type => :single_line_text, :name => "Patient middle name", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][street_number]" => {:type => :single_line_text, :name => "Patient street number", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][street_name]" => {:type => :single_line_text, :name => "Patient street name", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][unit_number]" => {:type => :single_line_text, :name => "Patient unit number", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][city]" => {:type => :single_line_text, :name => "Patient city", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][state_id]" => {:type => :single_line_text, :name => "Patient state", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][county_id]" => {:type => :single_line_text, :name => "Patient county", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][address][postal_code]" => {:type => :single_line_text, :name => "Patient zip code", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][birth_date]" => {:type => :date, :name => "Patient date of birth", :can_follow_up => false },
      "morbidity_event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => {:type => :single_line_text, :name => "Patient age", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][age_at_onset]" => {:type => :single_line_text, :name => "Age at onset", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][date_of_death]" => {:type => :date, :name => "Patient date of death", :can_follow_up => false },
      "morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]" => {:type => :single_line_text, :name => "Patient birth gender", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]" => {:type => :single_line_text, :name => "Patient ethnicity", :can_follow_up => true },
      "morbidity_event[active_patient][active_primary_entity][person][primary_language_id]" => {:type => :single_line_text, :name => "Patient primary language", :can_follow_up => true },
      # "morbidity_event[active_patient][active_primary_entity][race_ids][]" => {:type => :single_line_text, :name => "Patient race" }
      
      # Risk factors
      "morbidity_event[active_patient][participations_risk_factor][pregnant_id]" => {:type => :drop_down, :name => "Pregnant", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][pregnancy_due_date]" => {:type => :date, :name => "Pregnancy due date", :can_follow_up => false },
      "morbidity_event[active_patient][participations_risk_factor][food_handler_id]" => {:type => :drop_down, :name => "Food handler", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][healthcare_worker_id]" => {:type => :drop_down, :name => "Healthcare worker", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][group_living_id]" => {:type => :drop_down, :name => "Group living", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][day_care_association_id]" => {:type => :drop_down, :name => "Day care association", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][occupation]" => {:type => :single_line_text, :name => "Occupation", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][risk_factors]" => {:type => :single_line_text, :name => "Risk factors", :can_follow_up => true },
      "morbidity_event[active_patient][participations_risk_factor][risk_factors_notes]" => {:type => :multi_line_text, :name => "Risk factors notes", :can_follow_up => false },

      # Event-level fields
      "morbidity_event[results_reported_to_clinician_date]" => {:type => :single_line_text, :name => "Results reported to clinician date", :can_follow_up => false },
      "morbidity_event[first_reported_PH_date]" => {:type => :single_line_text, :name => "Date first reported to public health", :can_follow_up => false },
      "morbidity_event[lhd_case_status_id]" => {:type => :drop_down, :name => 'LHD case status', :can_follow_up => false },
      "morbidity_event[udoh_case_status_id]" => {:type => :drop_down, :name => 'UDOH case status', :can_follow_up => false },
      "morbidity_event[outbreak_associated_id]" => {:type => :drop_down, :name => 'Outbreak associated', :can_follow_up => true },
      "morbidity_event[outbreak_name]" => {:type => :single_line_text, :name => 'Outbreak', :can_follow_up => true },
      "morbidity_event[active_jurisdiction][secondary_entity_id]" => {:type => :multi_select, :name => 'Jurisdiction responsible for investigation', :can_follow_up => false },
      "morbidity_event[event_status]" => {:type => :drop_down, :name => 'Event status', :can_follow_up => false },
      "morbidity_event[investigation_started_date]" => {:type => :single_line_text, :name => 'Date investigation started', :can_follow_up => false },
      "morbidity_event[investigation_completed_LHD_date]" => {:type => :single_line_text, :name => 'Date investigation completed', :can_follow_up => false },
      "morbidity_event[event_name]" => {:type => :single_line_text, :name => 'Event name', :can_follow_up => true },
      "morbidity_event[review_completed_UDOH_date]" => {:type => :single_line_text, :name => 'Date review completed by UDOH', :can_follow_up => false },
      "morbidity_event[imported_from_id]" => {:type => :drop_down, :name => 'Imported from', :can_follow_up => true },
     
      # Reporting-level fields
      "morbidity_event[active_reporting_agency][active_secondary_entity][place][name]" => {:type => :drop_down, :name => 'Reporting agency', :can_follow_up => false },
      "morbidity_event[active_reporter][active_secondary_entity][person][first_name]" => {:type => :drop_down, :name => 'Reporter first name', :can_follow_up => true },
      "morbidity_event[active_reporter][active_secondary_entity][person][last_name]" => {:type => :drop_down, :name => 'Reporter last name', :can_follow_up => true },
      "morbidity_event[active_reporter][active_secondary_entity][telephone_entities_location][entity_location_type_id]" => {:type => :drop_down, :name => 'Reporter phone type', :can_follow_up => true },
      "morbidity_event[active_reporter][active_secondary_entity][telephone][area_code]" => {:type => :drop_down, :name => 'Reporter area code', :can_follow_up => true },
      "morbidity_event[active_reporter][active_secondary_entity][telephone][phone_number]" => {:type => :drop_down, :name => 'Reporter phone number', :can_follow_up => true },
      "morbidity_event[active_reporter][active_secondary_entity][telephone][extension]" => {:type => :drop_down, :name => 'Reporter extension', :can_follow_up => true },

      # Disease-level fields
      "morbidity_event[disease][disease_id]" => {:type => :drop_down, :name => 'Disease', :can_follow_up => false },
      "morbidity_event[disease][disease_onset_date]" => {:type => :date, :name => 'Disease onset date', :can_follow_up => false },
      "morbidity_event[disease][date_diagnosed]" => {:type => :date, :name => 'Disease date diagnosed', :can_follow_up => false },
      "morbidity_event[disease][hospitalized_id]" => {:type => :drop_down, :name => 'Hospitalized', :can_follow_up => true },
      "morbidity_event[disease][died_id]" => {:type => :drop_down, :name => 'Died', :can_follow_up => true },
      
      # Multiples wrappers
      "morbidity_event[contacts]" => {:type => :drop_down, :name => 'Contacts', :can_follow_up => false },
      "morbidity_event[places]" => {:type => :drop_down, :name => 'Places', :can_follow_up => false },
      "morbidity_event[treatments]" => {:type => :drop_down, :name => 'Treatments', :can_follow_up => false }
        
    }
  end
  
  def self.core_views
    [
      ["Demographics", "Demographics"], 
      ["Clinical", "Clinical"], 
      ["Laboratory", "Laboratory"], 
      ["Contacts", "Contacts"],
      ["Epidemiological", "Epidemiological"], 
      ["Reporting", "Reporting"], 
      ["Administrative", "Administrative"]
    ]
  end

  has_many :place_exposures, 
    :class_name => 'Participation',
    :foreign_key => "event_id",
    :conditions => ['role_id = ?', Code.place_exposure_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_one :reporting_agency, 
    :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.reporting_agency_type_id]

  has_one :reporter, 
    :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.reported_by_type_id]

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_place_exposures() end

  validates_associated :place_exposures
  validates_associated :reporting_agency
  validates_associated :reporter

  def new_place_exposure_attributes=(place_exposure_attributes)
    place_exposure_attributes.each do |attributes|
      next if attributes.values_blank?
      place_exposure_participation = place_exposures.build(:role_id => Event.participation_code('Place Exposure'))
      place_exposure_entity = place_exposure_participation.build_secondary_entity
      place_exposure_entity.entity_type = 'place'
      place_exposure_entity.build_place_temp(attributes)
    end
  end

  def existing_place_exposure_attributes=(place_exposure_attributes)
    place_exposures.reject(&:new_record?).each do |place_exposure|      
      attributes = place_exposure_attributes[place_exposure.secondary_entity.place_temp.id.to_s]
      if attributes
        place_exposure.secondary_entity.place_temp.attributes = attributes
      else
        place_exposures.delete(place_exposure)
      end
    end
  end

  def active_reporting_agency
    self.reporting_agency
  end

  def active_reporter
    self.reporter
  end

  # This hurts my head
  def active_reporting_agency=(attributes)
    return if attributes.values_blank? 

    # Handle the reporting agency.  Note, it's an auto-complete: user might have entered a new one or chosen an existing one.
    agency = attributes.delete(:name)
    entity_id = attributes.delete('secondary_entity_id')

    # First, the reporting agency
    unless agency.blank?
      # If there's no reporting agency associated with this event, then build the participation
      self.build_reporting_agency(:role_id => Event.participation_code('Reporting Agency')) if self.reporting_agency.nil?

      if entity_id.blank?
        # The entered agency was not chosen from the autocomplete list, create it
        new_agency =  Entity.new
        new_agency.entity_type = 'place'
        new_agency.build_place_temp(:name => agency, :place_type_id => Code.other_place_type_id)
        new_agency.save
        entity_id = new_agency.id
      end
      # Otherwise assign the (now) existing entity id to the participation
      self.reporting_agency.secondary_entity_id = entity_id 
    end

    # Now the reporter and reporter phone
    return if attributes.values_blank?

    # User can send either a reporter or a phone number or both.  Regardless we need a participation and an entity if we don't have one already
    self.build_reporter(:role_id => Event.participation_code('Reported By')).build_secondary_entity if self.reporter.nil?
    self.reporter.secondary_entity.entity_type = 'person'
    
    # Process the person, if any
    last_name = attributes.delete(:last_name)
    first_name = attributes.delete(:first_name)
    #
    # Build a person if we don't have one
    self.reporter.secondary_entity.build_person_temp if self.reporter.secondary_entity.person_temp.nil?
    self.reporter.secondary_entity.person_temp.attributes = { :last_name => last_name, :first_name => first_name }

    # Now do the phone, if any (attached to person, not agency)
    return if attributes.values_blank?

    # This is the existing entity_location_id (pointing at the phone), if any
    el_id = attributes.delete(:id).to_i

    # If there's no ID, then they are adding a new phone
    if el_id == 0 || el_id.blank?
      code = attributes.delete(:entity_location_type_id)
      # They might have selected a phone type (work, home, etc.) but nothing else, just bail.
      return if attributes.values_blank?

      # Build the phone
      el = self.reporter.secondary_entity.telephone_entities_locations.build(
          :entity_location_type_id => code, 
          :primary_yn_id => ExternalCode.yes_id,
          :location_type_id => Code.telephone_location_type_id)
      el.build_location.telephones.build(attributes)
    else
      # Don't just 'find' the existing phone, loop through the association array looking for it
      self.reporter.secondary_entity.telephone_entities_locations.each do |tel_el|
        p tel_el.id
        p el_id
        if tel_el.id == el_id
          tel_el.entity_location_type_id = attributes.delete(:entity_location_type_id)
          tel_el.location.telephones.last.attributes = attributes
          break
        end
      end
    end
  end

  def route_to_jurisdiction(jurisdiction, secondary_jurisdiction_ids=[])
    jurisdiction_id = jurisdiction.to_i if jurisdiction.respond_to?('to_i')
    jurisdiction_id = jurisdiction.id if jurisdiction.is_a? Entity
    jurisdiction_id = jurisdiction.entity_id if jurisdiction.is_a? Place

    transaction do
      # Handle the primary jurisdiction
      # 
      # Do nothing if the passed-in jurisdiction is the current jurisdiction
      unless jurisdiction_id == active_jurisdiction.secondary_entity_id
        proposed_jurisdiction = Entity.find(jurisdiction_id) # Will raise an exception if record not found
        raise "New jurisdiction is not a jurisdiction" if proposed_jurisdiction.current_place.place_type_id != Code.find_by_code_name_and_the_code('placetype', 'J').id
        active_jurisdiction.update_attribute("secondary_entity_id", jurisdiction_id)
        update_attribute("event_queue_id",  nil)
      end

      # Handle secondary jurisdictions
      #
      existing_secondary_jurisdiction_ids = associated_jurisdictions.collect { |participation| participation.secondary_entity_id }

      # if an existing secondary jurisdiction ID is not in the passed-in ids, delete
      (existing_secondary_jurisdiction_ids - secondary_jurisdiction_ids).each do |id_to_delete|
        associated_jurisdictions.delete(associated_jurisdictions.find_by_secondary_entity_id(id_to_delete))
      end

      # if an passed-in ID is not in the existing secondary jurisdiction IDs, add
      (secondary_jurisdiction_ids - existing_secondary_jurisdiction_ids).each do |id_to_add|
        associated_jurisdictions.create(:secondary_entity_id => id_to_add, :role_id => Event.participation_code('Secondary Jurisdiction'))
      end

      reload # Any existing references to this object won't see these changes without this
    end
  end

  def save_associations
    super

    if reporting_agency
      reporting_agency.save(false)
      reporting_agency.secondary_entity.place_temp.save(false)
    end

    if reporter
      reporter.save(false)
      reporter.secondary_entity.person_temp.save(false) if reporter.secondary_entity.person_temp

      reporter.secondary_entity.telephone_entities_locations.each do |el|
        el.save(false)
        el.location.telephones.each { |t| t.save(false) }
      end
    end

    place_exposures.each do |pe|
      pe.secondary_entity.place_temp.save(false)
    end
  end

end
