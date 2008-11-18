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

class HumanEvent < Event
  include Export::Cdc::HumanEvent

  before_validation_on_create :set_age_at_onset
  before_validation_on_update :set_age_at_onset

  has_one :patient, :class_name => 'Participation', 
    :conditions => ["role_id = ?", Code.interested_party_id], 
    :foreign_key => "event_id"

  has_many :labs, :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.tested_by_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :hospitalized_health_facilities, :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.hospitalized_at_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :diagnosing_health_facilities, :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.diagnosed_at_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  has_many :clinicians, :class_name => 'Participation', 
    :foreign_key => "event_id",
    :conditions => ["role_id = ?", Code.treated_by_type_id],
    :order => 'created_at ASC',
    :dependent => :destroy

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_labs() end
  def validate_associated_records_for_hospitalized_health_facilities() end
  def validate_associated_records_for_diagnosing_health_facilities() end
  def validate_associated_records_for_clinicians() end

  validates_associated :patient
  validates_associated :labs
  validates_associated :hospitalized_health_facilities
  validates_associated :diagnosing_health_facilities
  validates_associated :clinicians

  def active_patient
    self.patient
  end
  
  def active_patient=(attributes)
    self.patient = Participation.new_patient_participation if self.patient.nil?
    self.patient.participations_risk_factor = attributes.delete(:participations_risk_factor) if attributes.has_key?(:participations_risk_factor)
    self.patient.new_treatment_attributes = attributes.delete(:new_treatment_attributes) if attributes.has_key?(:new_treatment_attributes)
    self.patient.existing_treatment_attributes = attributes.delete(:existing_treatment_attributes) if attributes.has_key?(:existing_treatment_attributes)
    self.patient.primary_entity.attributes = attributes
  end

  def new_lab_attributes=(lab_attributes)
    lab_attributes.each do |attributes|
      next if attributes.values_blank?

      lab_entity_id = attributes.delete("lab_entity_id")
      lab_name = attributes.delete("name")
      lab_name = nil if lab_name.blank?
      lab_participation = nil

      # If lab_entity_id has a value then the place already exists
      unless lab_entity_id.blank?
        # Check to see if there's an existing participation for the lab
        # We search the labs array, rather than use AR #find, so we can build the association in memory for the @event.save that's soon to come
        lab_participation = labs.detect { |lab| lab.secondary_entity_id == lab_entity_id.to_i }

        # Participation does not exist, create one and link to existing lab
        if lab_participation.nil?
          lab_participation = labs.build(:role_id => Event.participation_code('Tested By'))
          lab_participation.secondary_entity_id = lab_entity_id
        else
          # participation already exists, do nothing
        end
      else
        # New lab. Create participation, entity, and place, linking each to the next
        lab_participation = labs.build(:role_id => Event.participation_code('Tested By'))
        lab_entity = lab_participation.build_secondary_entity
        lab_entity.entity_type = "place"
        lab_entity.build_place_temp( {:name => lab_name, :place_type_id => Code.find_by_code_name_and_code_description("placetype", "Laboratory").id} )
      end

      # Build a new lab_result and associate with the participation
      lab_participation.lab_results.build(attributes)
    end
  end
  
  # We're not allowing editing lab names, just lab results
  def existing_lab_attributes=(lab_attributes)

    # loop through all lab participations and their lab_results, ignoring any just added by new_lab_attributes
    labs.reject(&:new_record?).each do |lab|
      lab.lab_results.reject(&:new_record?).each do |lab_result|

        # Note the "id" here is the lab_result ID, not the lab ID as in new_lab_attributes
        # If there are attributes for that ID, then the lab result has not been deleted, update the attributes in memory
        attributes = lab_attributes[lab_result.id.to_s]
        if attributes && !attributes.values_blank?
          lab_result.attributes = attributes
        else
          # Array (not activerecord) deletion.  Make this a soft delete when we get to it
          lab.lab_results.delete(lab_result)
        end
      end
    end
  end

  def new_hospital_attributes=(hospital_attributes)
    hospital_attributes.each do |attributes|
      next if attributes.values_blank?
      hospital_participation = hospitalized_health_facilities.build(:role_id => Event.participation_code('Hospitalized At'))
      # Hospitals are a drop down of existing places, not an autocomplete.  Just assgn.
      hospital_participation.secondary_entity_id = attributes.delete("secondary_entity_id")
      hospital_participation.build_hospitals_participation(attributes) unless attributes.values_blank?
    end
  end

  def existing_hospital_attributes=(hospital_attributes)
    hospitalized_health_facilities.reject(&:new_record?).each do |hospital|
      attributes = hospital_attributes[hospital.id.to_s]
      if attributes && !attributes.values_blank?
        hospital.secondary_entity_id = attributes.delete("secondary_entity_id")
        unless attributes.values_blank?
          if hospital.hospitals_participation.nil?
            hospital.hospitals_participation = HospitalsParticipation.new(attributes)
          else
            hospital.hospitals_participation.attributes = attributes
          end
        end
      else
        hospitalized_health_facilities.delete(hospital)
      end
    end
  end

  def new_diagnostic_attributes=(diagnostic_attributes)
    diagnostic_attributes.each do |attributes|
      next if attributes.values_blank?
      diagnostic_participation = diagnosing_health_facilities.build(:role_id => Event.participation_code('Diagnosed At'))
      # Diagnostic facilities are a drop down of existing places, not an autocomplete.  Just assgn.
      diagnostic_participation.secondary_entity_id = attributes.delete("secondary_entity_id")
    end
  end

  def existing_diagnostic_attributes=(diagnostic_attributes)
    diagnosing_health_facilities.reject(&:new_record?).each do |diagnostic|
      attributes = diagnostic_attributes[diagnostic.id.to_s]
      if attributes && !attributes.values_blank?
        diagnostic.secondary_entity_id = attributes.delete("secondary_entity_id")
      else
        diagnosing_health_facilities.delete(diagnostic)
      end
    end
  end

  def new_clinician_attributes=(clinician_attributes)
    clinician_attributes.each do |attributes|
      code = attributes.delete(:entity_location_type_id)
      next if attributes.values_blank?

      person = {}
      person[:last_name] = attributes.delete(:last_name)
      person[:first_name] = attributes.delete(:first_name)
      person[:middle_name] = attributes.delete(:middle_name)

      clinician_participation = clinicians.build(:role_id => Event.participation_code('Treated By'))
      clinician_entity = clinician_participation.build_secondary_entity
      clinician_entity.entity_type = "person"
      clinician_entity.build_person_temp( person )

      next if attributes.values_blank?
      el = clinician_entity.telephone_entities_locations.build(
             :entity_location_type_id => code, 
             :primary_yn_id => ExternalCode.yes_id,
             :location_type_id => Code.telephone_location_type_id)
      el.build_location.telephones.build(attributes)
    end
  end

  def existing_clinician_attributes=(clinician_attributes)
    clinicians.reject(&:new_record?).each do |clinician|
      attributes = clinician_attributes[clinician.secondary_entity.person_temp.id.to_s]

      # Which entity_location (phone) to edit is passed along in the (hidden) attribute clinician_phone_id
      el_id = attributes.delete(:clinician_phone_id).to_i if attributes

      if attributes && !attributes.values_blank?
        person = {}
        person[:last_name] = attributes.delete(:last_name)
        person[:first_name] = attributes.delete(:first_name)
        person[:middle_name] = attributes.delete(:middle_name)

        clinician.secondary_entity.person_temp.attributes = person

        # They may be adding a phone number to an existing clinician who did not already have one
        if el_id == 0 || el_id.blank?
          code = attributes.delete(:entity_location_type_id)
          next if attributes.values_blank?
          el = clinician.secondary_entity.telephone_entities_locations.build(
                 :entity_location_type_id => code, 
                 :primary_yn_id => ExternalCode.yes_id,
                 :location_type_id => Code.telephone_location_type_id)
          el.build_location.telephones.build(attributes)
        else
          # Don't just find it, loop through the association array looking for it
          clinician.secondary_entity.telephone_entities_locations.each do |tel_el|
            if tel_el.id == el_id
              # If the clinician had a phone number and the user blanked it out, delete it
              if attributes.values_blank?
                tel_el.destroy
                tel_el.location.destroy
              else
                tel_el.entity_location_type_id = attributes.delete(:entity_location_type_id)
                tel_el.location.telephones.last.attributes = attributes
              end
              break
            end
          end
        end
      else
        # Removes the participation.  Leaves the entity (with phone) intact.
        clinicians.delete(clinician)
      end
    end
  end

  def lab_results
    @results ||= (
      results = []
      labs.each do |lab|
        lab.lab_results.each do |lab_result|
          results << lab_result
        end
      end
      results
    )
  end

  def save_associations
    patient.save(false)
    patient.primary_entity.save(false)

    labs.each do |lab|
      if lab.lab_results.length == 0
        lab.destroy
        next
      end
      lab.save(false)
      lab.lab_results.each do |lab_result|
        lab_result.save(false)
      end
    end

    hospitalized_health_facilities.each do |hospital|
      hospital.save(false)
      hospital.hospitals_participation.save(false) unless hospital.hospitals_participation.nil?
    end

    diagnosing_health_facilities.each do |diagnostic|
      diagnostic.save(false)
    end
    
    clinicians.each do |clinician|
      clinician.secondary_entity.person_temp.save(false)
      clinician.secondary_entity.telephone_entities_locations.each do |el|
        # Unless the phone number was destroyed, save it
        unless el.frozen?
          el.save(false)
          el.location.telephones.each { |t| t.save(false) }
        end
      end
    end

    super
  end

  private

  def set_age_at_onset
    birthdate = safe_call_chain(:active_patient, :primary_entity, :person_temp, :birth_date)
    onset = onset_candidate_dates.compact.sort.first
    # return unless birthdate && onset
    self.age_info = AgeInfo.create_from_dates(birthdate, onset)
  end

  def onset_candidate_dates
    dates = [self.event_onset_date]
    dates << safe_call_chain(:disease, :date_diagnosed)
    self.labs.each do |l| 
      l.lab_results.each do |r| 
        dates << r.collection_date 
        dates << r.lab_test_date
      end
    end
    dates << self.created_at.to_date unless self.created_at.nil?
    dates << self.first_reported_PH_date
    dates
  end
end
