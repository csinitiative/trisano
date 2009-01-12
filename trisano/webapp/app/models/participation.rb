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

class Participation < ActiveRecord::Base
  belongs_to :event
  belongs_to :primary_entity, :foreign_key => :primary_entity_id, :class_name => 'Entity'
  belongs_to :secondary_entity, :foreign_key => :secondary_entity_id, :class_name => 'Entity'
  belongs_to :participations_place
  belongs_to :participations_contact
  
  has_many :lab_results, :order => 'created_at ASC', :dependent => :destroy
  has_one :hospitals_participation, :dependent => :destroy
  has_many :participations_treatments, :dependent => :destroy, :order => 'created_at ASC'
  has_one :participations_risk_factor, :order => 'created_at ASC'

  belongs_to :participating_event, :class_name => 'Event', :foreign_key => 'participating_event_id'

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_lab_results() end
  def validate_associated_records_for_participations_treatments() end

  validates_associated :primary_entity
  validates_associated :secondary_entity
  validates_associated :lab_results
  validates_associated :hospitals_participation
  validates_associated :participations_treatments
  validates_associated :participations_place
  validates_associated :participations_contact

  after_update :save_multiples

  class << self
    def new_lab_participation
      lab_participation = Participation.new_place_participation
      lab_participation.lab_results.build
      lab_participation
    end

    def new_hospital_participation
      hospital_participation = Participation.new_place_participation
      hospital_participation.build_hospitals_participation
      hospital_participation
    end

    def new_diagnostic_participation
      Participation.new_place_participation
    end

    def new_contact_participation
      contact_participation = Participation.new_secondary_person_with_phone_participation
      contact_participation.build_participations_contact
      contact_participation
    end

    def new_place_participation
      place_participation = Participation.new
      place_participation.build_secondary_entity.build_place_temp
      place_participation.secondary_entity.entity_type = "place"
      place_participation
    end

    def new_secondary_person_participation
      person_participation = Participation.new
      person_participation.build_secondary_entity.build_person_temp
      person_participation.secondary_entity.entity_type = "person"
      person_participation
    end

    def new_secondary_person_with_phone_participation
      pwp_participation = Participation.new_secondary_person_participation
      pwp_participation.secondary_entity.telephone_entities_locations.build(
        :primary_yn_id => ExternalCode.yes_id,
        :location_type_id => Code.telephone_location_type_id).build_location.telephones.build
      pwp_participation
    end

    def new_reporting_agency_participation
      ra_participation = Participation.new_place_participation
      ra_participation.role_id = Event.participation_code('Reporting Agency')
      ra_participation
    end

    def new_reporter_participation
      reporter_participation = Participation.new_secondary_person_with_phone_participation
      reporter_participation.role_id = Event.participation_code('Reported By')
      reporter_participation
    end

    def new_patient_participation(existing_entity=nil)
      patient = Participation.new
      patient.role_id = Code.interested_party_id
      if existing_entity
        patient.primary_entity_id = existing_entity.id
      else
        patient.build_primary_entity.build_person_temp
        patient.primary_entity.entity_type = "person"
      end
      patient
    end

    def new_exposure_participation
      exposure = Participation.new_place_participation
      exposure.role_id = Event.participation_code('Place Exposure')
      exposure.build_participations_place
      exposure
    end

    def new_patient_participation_with_address_and_phone
      patient = Participation.new_patient_participation
      patient.primary_entity.address_entities_locations.build( 
        :primary_yn_id => ExternalCode.yes.id,
        :location_type_id => Code.address_location_type_id).build_location.addresses.build
      patient.primary_entity.telephone_entities_locations.build( 
        :primary_yn_id => ExternalCode.yes.id,
        :location_type_id => Code.telephone_location_type_id).build_location.telephones.build
      patient
    end

    def new_jurisdiction_participation
      jurisdiction = Participation.new(:role_id => Event.participation_code('Jurisdiction'))
      jurisdiction.secondary_entity = (User.current_user.jurisdictions_for_privilege(:create_event).first || Place.jurisdiction_by_name("Unassigned")).entity
      jurisdiction
    end

    def new_clinician_participation
      Participation.new_secondary_person_with_phone_participation
    end
  end

  def participations_risk_factor=(attributes)
    if attributes.values_blank? && !participations_risk_factor.nil?
      participations_risk_factor.destroy
    end
    return if attributes.values_blank?
    self.build_participations_risk_factor if participations_risk_factor.nil?
    self.participations_risk_factor.attributes = attributes
  end  

  def new_treatment_attributes=(treatment_attributes)
    treatment_attributes.each do |attributes|
      next if attributes.values_blank?
      treatment = self.participations_treatments.build(attributes)
    end
  end

  def existing_treatment_attributes=(treatment_attributes)
    participations_treatments.reject(&:new_record?).each do |treatment|
      attributes = treatment_attributes[treatment.id.to_s]
      if attributes && !attributes.values_blank?
        treatment.attributes = attributes
      else
        participations_treatments.delete(treatment)
      end
    end
  end

  # For backwards compatibility.  Currently only used by form builder core field configs and follow-ups.
  def active_secondary_entity
    self.secondary_entity
  end

  # For backwards compatibility.  Currently only used by form builder core field configs and follow-ups.
  def active_primary_entity
    self.primary_entity
  end

  private

  def validate
    if !hospitals_participation.nil? and secondary_entity.nil?
      errors.add_to_base("Hospital can not be blank if hospitalization dates or medical record number are given.")
    end
  end

  def save_multiples
    participations_treatments.each do |treatment|
      treatment.save(false)
    end
    
    participations_risk_factor.save unless participations_risk_factor.nil? || participations_risk_factor.frozen?
  end

end
