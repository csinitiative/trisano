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

class StagedMessage < ActiveRecord::Base
  class << self
    def states
      { :pending  => 'PENDING',
        :assigned => 'ASSIGNED'
      }
    end
  end

  belongs_to :event, :autosave => true

  before_validation :strip_line_feeds
  before_validation_on_create :set_state

  validates_presence_of :hl7_message
  validates_length_of :hl7_message, :maximum => 10485760
  validates_inclusion_of :state, :in => self.states.values

  attr_protected :state

  def validate
    begin
      hl7
    rescue
      errors.add :hl7_message, "could not be parsed"
      return
    end

    errors.add :hl7_message, "is missing the header" if self.message_header.nil?

    # If any of these are missing, the parser sets them all to nil :(
    if self.observation_request.nil? || self.observation_request.tests.empty? || self.patient.nil?
      errors.add :hl7_message, "is missing one or more of the following segments: PID, OBR, or OBX"
      return
    end

    errors.add :hl7_message, "No last name provided for patient." if self.patient.patient_last_name.blank?
  end
  
  def hl7
    @hl7 ||= HL7::Message.new(self.hl7_message)
  end

  def message_header
    hl7.message_header
  end

  # For now, we support only one OBR record per HL7 message
  def observation_request
    hl7.observation_request
  end

  def patient
    hl7.patient_id
  end

  def assigned_event=(event)
    raise(ArgumentError, "Cannot associated labs with #{event.class}") unless event.respond_to?('labs')
    raise("Staged message is already assigned to an event.") if self.state == self.class.states[:assigned]

    event.add_labs_from_staged_message(self)
    self.event = event
    self.state = self.class.states[:assigned]
    self.save!
  end

  def assigned_event
    self.event
  end

  def new_event_from
    return nil if self.patient.patient_last_name.blank?

    event = MorbidityEvent.new(:workflow_state => 'new', :event_onset_date => Date.today)
    event.build_interested_party 
    event.interested_party.build_person_entity(:race_ids => [self.patient.trisano_race_id])
    event.interested_party.person_entity.build_person( :last_name => self.patient.patient_last_name,
                                                       :first_name => self.patient.patient_first_name,
                                                       :middle_name => self.patient.patient_middle_name,
                                                       :birth_date => self.patient.birth_date,
                                                       :birth_gender_id => self.patient.trisano_sex_id)


    unless self.patient.address_empty?
      event.build_address(:street_number => self.patient.address_street_no,
                          :unit_number => self.patient.address_unit_no,
                          :street_name => self.patient.address_street,
                          :city => self.patient.address_city,
                          :state_id => self.patient.address_trisano_state_id,
                          :postal_code => self.patient.address_zip)
    end

    unless self.patient.telephone_empty?
      area_code, number, extension = self.patient.telephone_home
      event.interested_party.person_entity.telephones.build(:area_code => area_code,
                                                            :phone_number => number,
                                                            :extension => extension,
                                                            :entity_location_type_id => ExternalCode.find_by_code_name_and_the_code('telephonelocationtype', 'HT').id)
    end

    event.build_jurisdiction unless event.jurisdiction
    event.jurisdiction.secondary_entity = (User.current_user.jurisdictions_for_privilege(:create_event).first || Place.jurisdiction_by_name("Unassigned")).entity
    event
  end

  private

  def set_state
    self.state = self.class.states[:pending] if self.state.nil?
  end

  def strip_line_feeds
    # Line feeds are used as End Of Message characters in HL7.  All other uses should be squelched.
    # Maybe a little dangerous, but it should be okay.
    # Especially useful for POSTing messages in directly
    return if hl7_message.nil?
    self.hl7_message.gsub!(/\n/, '')
    self.hl7_message << "\n"
  end
end
