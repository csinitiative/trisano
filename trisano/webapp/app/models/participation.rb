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

  has_many :lab_results, :order => 'created_at ASC', :dependent => :destroy
  #TGR: Remove auditing (has_many) for now.
  has_one :hospitals_participation, :dependent => :destroy
  has_many :participations_treatments, :order => 'created_at ASC'
  has_many :participations_risk_factors, :order => 'created_at ASC'

  validates_associated :primary_entity
  validates_associated :secondary_entity
  validates_associated :lab_results
  validates_associated :hospitals_participation

  before_validation :save_associations

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
      contact_participation = Participation.new_person_participation
      contact_participation.secondary_entity.entities_locations.build( 
        :primary_yn_id => ExternalCode.yes_id,
        :location_type_id => Code.telephone_location_type_id,
        :entity_location_type_id => ExternalCode.telephone_location_type_ids[0]).build_location.telephones.build
      contact_participation
    end

    def new_place_participation
      place_participation = Participation.new
      place_participation.build_secondary_entity.build_place_temp
      place_participation
    end

    def new_person_participation
      person_participation = Participation.new
      person_participation.build_secondary_entity.build_person_temp
      person_participation
    end

    def new_patient_participation
      patient = Participation.new
      patient.build_primary_entity.build_person_temp
      patient.primary_entity.address = {}
      patient.primary_entity.entities_locations.build( 
        :entity_location_type_id => ExternalCode.telephone_location_type_ids[0])
      patient.role_id = Code.interested_party.id
      patient
    end

  end

  def active_primary_entity
    @active_primary_entity || primary_entity
  end

  def active_primary_entity=(attributes)
    if new_record?
      @active_primary_entity = Entity.new(attributes)
    else
      active_primary_entity.update_attributes(attributes)
    end
  end

  def active_secondary_entity
    @active_secondary_entity || secondary_entity
  end

  def active_secondary_entity=(attributes)
    if new_record?
      @active_secondary_entity = Entity.new(attributes)
    else
      active_secondary_entity.update_attributes(attributes)
    end
  end

  def participations_treatment
    @participations_treatment ||= ParticipationsTreatment.new
  end

  def participations_treatment=(attributes)
    @participations_treatment = participations_treatments.build(attributes) unless attributes[:treatment].blank?
  end  

  def participations_risk_factor
    @participations_risk_factor ||= participations_risk_factors.last
  end

  def participations_risk_factor=(attributes)
    @participations_risk_factor = participations_risk_factors.build(attributes)
  end  

  private

  def validate
    if !hospitals_participation.nil? and secondary_entity.nil?
      errors.add_to_base("Hospital can not be blank if hospitalization dates or medical record number are given.")
    end
  end

  def save_associations
    self.primary_entity = @active_primary_entity unless Utilities::model_empty?(@active_primary_entity)
    self.secondary_entity = @active_secondary_entity unless Utilities::model_empty?(@active_secondary_entity)
  end
end
