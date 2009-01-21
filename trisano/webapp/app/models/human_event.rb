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

  validates_numericality_of :age_at_onset,
    :allow_nil => true,
    :greater_than_or_equal_to => 0,
    :only_integer => true,
    :message => 'is negative. This is usually caused by an incorrect onset date or birth date.'

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
    
    # Contacts only, update only
    if attributes.has_key?(:participations_contact)
      self.patient.build_participations_contact unless self.patient.participations_contact
      self.patient.participations_contact.attributes = attributes.delete(:participations_contact) if attributes.has_key?(:participations_contact)
    end

    self.patient.primary_entity.attributes = attributes
  end

  # Lab attributes is a hash (not an array) of lab_names (some possibly new).  The lab may have lab_result children - always new.
  # It's a hash so that it has a unique HTML name and thus can have children
  def new_lab_attributes=(lab_attributes)
    # A hash that tracks all previously unknown labs sent in with the current POST
    earlier_labs = {}

    # We don't care that lab_attribues is a hash (rails does), loop through new lab names like it's an array.
    lab_attributes.each_value do |attributes|
      next if attributes.values_blank?

      lab_name = attributes["name"]
      lab_name = nil if lab_name.blank? # to trigger validation error

      # All new labs are new lab participations.  If they've typed in the same lab 2 or more times, so be it.
      lab_participation = labs.build(:role_id => Event.participation_code('Tested By'))

      # Check to see if we already know this lab
      existing_lab = Place.find_by_name_and_place_type_id(lab_name, Code.lab_place_type_id)

      if existing_lab
        # Simply assign the ID 
        lab_participation.secondary_entity_id = existing_lab.entity_id
      else
        # Event though we happily create participations that point at the same lab, lets not create multiple identical labs
        if entity = earlier_labs[lab_name]
          lab_participation.secondary_entity = entity
        else
          lab_entity = lab_participation.build_secondary_entity
          lab_entity.entity_type = "place"
          lab_entity.build_place_temp( {:name => lab_name, :place_type_id => Code.lab_place_type_id} )

          # Memorize lab name and entity
          earlier_labs[lab_name] = lab_entity
        end
      end

      # Loop through all lab results and attach to lab participation
      if new_results = attributes["new_lab_result_attributes"] || []    # Is not possible via the UI, but...
        new_results.each do |result_attributes|
          lab_participation.lab_results.build(result_attributes)
        end
      end

    end
  end
  
  # Edits to existing labs can include: deletion of individual results, deletion of a lab and all its results, a modification to lab
  # name (with either a new or existing lab), modification of existing lab results, or the addition of new new lab results.
  def existing_lab_attributes=(lab_attributes)
    # A hash that tracks all previously unknown labs sent in with the current POST
    earlier_labs = {}

    # loop through all lab participations, ignoring any just added by new_lab_attributes
    labs.reject(&:new_record?).each do |lab|

      # Get any changes to this lab from the POST params
      attributes = lab_attributes[lab.id.to_s]

      # If there are attributes for the current lab, then the lab has not been deleted, update the attributes in memory
      if attributes && !attributes.values_blank?
        lab_name = attributes["name"]
        lab_name = nil if lab_name.blank? # to trigger validation error

        # Is the POSTed lab name a known lab
        existing_lab = Place.find_by_name_and_place_type_id(lab_name, Code.lab_place_type_id)

        if existing_lab
          # Simply assign the ID 
          lab.secondary_entity_id = existing_lab.entity_id
        else
          # Has this lab been seen before in this POST?  In other words, did the user change two or more distinct existing labs to the same
          # previously unknown lab?  If so, avoide creating the lab entity twice.
          if entity = earlier_labs[lab_name]
            lab.secondary_entity = entity
          else
            # They've changed the lab name to a lab not seen before.
            # Create linked entity and place, then link to this participation.  Do not delete the previous lab
            lab_entity = Entity.new
            lab_entity.entity_type = "place"
            lab_entity.build_place_temp( {:name => lab_name, :place_type_id => Code.lab_place_type_id} )
            lab.secondary_entity = lab_entity
            
            # Memorize lab name and entity
            earlier_labs[lab_name] = lab_entity
          end
        end

        # Now, handle the changed or deleted (but not added) lab_results

        # Get the hash of POSTed existing lab results, passed in as a child of this lab
        existing_result_attributes = attributes[:existing_lab_result_attributes] || {} 

        # Copy the lab_results array and use that, so that we can delete from lab_results without skipping the next element 
        lab_results_copy = lab.lab_results.dup

        lab_results_copy.each do |lab_result|
          # If there are attributes for that ID, then the lab result has not been deleted, update the attributes in memory
          result_attributes = existing_result_attributes[lab_result.id.to_s]
          if result_attributes && !result_attributes.values_blank?
            lab_result.attributes = result_attributes
          else
            lab.lab_results.delete(lab_result)
          end
        end

        # Now, handle the added lab_results

        # Get the hash of POSTed new lab results, passed in as a child of this lab
        new_result_attributes = attributes[:new_lab_result_attributes] || [] 

        # Assign lab results to lab
        new_result_attributes.each do |result_attributes|
          next if result_attributes.values_blank?
          lab.lab_results.build(result_attributes)
        end

      else
        # The lab and all its results have been deleted
        labs.delete(lab)
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

      if attributes["entity_id"].blank?
        diagnostic_entity = diagnostic_participation.build_secondary_entity
        diagnostic_entity.entity_type = 'place'
        diagnostic_entity.build_place_temp(attributes)
      else
        diagnostic_entity = Entity.find(attributes["entity_id"])
        diagnostic_participation.secondary_entity = diagnostic_entity
      end
    end
  end

  def existing_diagnostic_attributes=(diagnostic_attributes)
    diagnosing_health_facilities.reject(&:new_record?).each do |diagnostic|
      attributes = diagnostic_attributes[diagnostic.id.to_s]
      # You can't edit diagnostic facilities, but you can delete the linkage.  So, if they're there, do nothing
      if attributes && !attributes.values_blank?
      else
        diagnosing_health_facilities.delete(diagnostic)
      end
    end
  end

  def new_clinician_attributes=(clinician_attributes)
    clinician_attributes.each do |attributes|
      code = attributes.delete(:entity_location_type_id)
      next if attributes.values_blank?

      clinician_participation = clinicians.build(:role_id => Event.participation_code('Treated By'))
      if attributes[:entity_id].blank?
        person = {:person_type => "clinician"}
        person[:last_name] = attributes.delete(:last_name)
        person[:first_name] = attributes.delete(:first_name)
        person[:middle_name] = attributes.delete(:middle_name)

        attributes.delete(:entity_id) # Get this out of the way

        clinician_entity = clinician_participation.build_secondary_entity
        clinician_entity.entity_type = "person"
        clinician_entity.build_person_temp( person )

        next if attributes.values_blank?
        el = clinician_entity.telephone_entities_locations.build(
               :entity_location_type_id => code, 
               :primary_yn_id => ExternalCode.yes_id,
               :location_type_id => Code.telephone_location_type_id)
        el.build_location.telephones.build(attributes)
      else
        clinician_entity = Entity.find(attributes[:entity_id])
        clinician_participation.secondary_entity = clinician_entity
      end
    end
  end

  def existing_clinician_attributes=(clinician_attributes)
    # first, preserve existing and delete removed
    clinicians.reject(&:new_record?).each do |clinician|
      attributes = clinician_attributes[clinician.id.to_s]
      # You can't edit clinicians but you can delete the linkage.  So, if they're there, do nothing
      if attributes && !attributes.values_blank?
      else
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

  def definitive_lab_result
    # CDC calculations expect one lab result.  Choosing the most recent to be it
    return nil if lab_results.empty?
    self.lab_results.sort_by { |lab_result| lab_result.lab_test_date || Date.parse("01/01/0000") }.last
  end

  def save_associations
    patient.save(false)
    patient.primary_entity.save(false)

    # Contacts only
    patient.participations_contact.save(false) if patient.participations_contact

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
    onset = onset_candidate_dates.compact.first
    self.age_info = AgeInfo.create_from_dates(birthdate, onset)    
  end

  def onset_candidate_dates
    dates = []
    dates << safe_call_chain(:disease, :disease_onset_date)
    dates << safe_call_chain(:disease, :date_diagnosed)
    collections = []
    test_dates = []
    self.labs.each do |l| 
      l.lab_results.collect{|r| collections << r.collection_date}
      l.lab_results.collect{|r| test_dates << r.lab_test_date}
    end
    dates << collections.compact.sort
    dates << test_dates.compact.sort
    dates << self.first_reported_PH_date
    dates << self.event_onset_date
    dates << self.created_at.to_date unless self.created_at.nil?
    dates.flatten
  end
end
