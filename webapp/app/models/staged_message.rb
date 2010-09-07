# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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
  class StagedMessageError < StandardError
  end

  class UnknownLoincCode < StagedMessageError
  end

  class UnlinkedLoincCode < StagedMessageError
  end

  class BadMessageFormat < StagedMessageError
  end

  class << self
    def states
      { :pending       => 'PENDING',
        :assigned      => 'ASSIGNED',
        :discarded     => 'DISCARDED',
        :unprocessable => 'UNPROCESSABLE'
      }
    end

    # TODO make these named scopes, for readability
    def find_by_search(criteria)
      with_last_name_starting criteria[:last_name] do
        with_first_name_starting criteria[:first_name] do
          with_lab_name_containing criteria[:laboratory] do
            with_collection_date_between criteria[:start_date], criteria[:end_date] do
              with_test_type_containing criteria[:test_type] do
                return [] unless scoped? :find
                all
              end
            end
          end
        end
      end
    end

    def with_first_name_starting(first_name, &block)
      with_scope_unless first_name.blank?, :find => {:conditions => ["patient_first_name ILIKE ?", "#{first_name}%"] }, &block
    end

    def with_last_name_starting(last_name, &block)
      with_scope_unless last_name.blank?, :find => {:conditions => ["patient_last_name ILIKE ?", "#{last_name}%"] }, &block
    end

    def with_lab_name_containing(lab_name, &block)
      with_scope_unless lab_name.blank?, :find => {:conditions => ["laboratory_name ILIKE ?", "%#{lab_name}%"] }, &block
    end

    def with_test_type_containing(test_type, &block)
      with_scope_unless(test_type.blank?,
                        :find => {
                          :conditions => ["test_type ILIKE ?", "%#{test_type}%"],
                          :joins => [:staged_observations],
                          :select => 'DISTINCT ON(staged_messages.id) staged_messages.*' },
                        &block)
    end

    def with_collection_date_between(start_date, end_date, &block)
      with_scope_unless start_date.blank? && end_date.blank?, :find => {:conditions => ["collection_date BETWEEN ? AND ?", start_date, end_date] }, &block
    end
  end

  has_many :lab_results
  has_many :staged_observations

  before_validation :strip_line_feeds
  before_validation_on_create :set_state
  after_validation_on_create  :set_searchable_attributes

  validates_presence_of :hl7_message
  validates_length_of :hl7_message, :maximum => 10485760
  validates_inclusion_of :state, :in => self.states.values

  attr_protected :state

  def validate
    begin
      hl7
    rescue
      errors.add :hl7_message, :parse_error
      return
    end

    errors.add :hl7_message, :missing_header if self.message_header.nil?

    if observation_requests.empty? || patient.nil?
      errors.add :hl7_message, :missing_segment
      return
    end

=begin
    # This may be OK.  The OBX segments may appear as children of SPM
    # segments rather than directly as children of the OBR segment.
    # Need to look further into what sort of validation is appropriate.
    observation_requests.each do |obr|
      if obr.tests.empty?
        errors.add :hl7_message, :missing_segment
        return
      end
    end
=end

    errors.add :hl7_message, :missing_last_name if self.patient.patient_last_name.blank?

    observation_requests.each do |obr|
      obr.all_tests.each do |test|
        errors.add :hl7_message, :missing_loinc,
          :segment => test.set_id if test.loinc_code.blank?
      end
    end
  end

  def hl7
    @hl7 ||= HL7::Message.new(self.hl7_message)
  end

  def message_header
    hl7.message_header
  end

  def observation_requests
    hl7.observation_requests
  end

  def patient
    hl7.patient_id
  end

  def assigned_event=(event)
    raise(ArgumentError, I18n.translate('cannot_associate_labs_with', :event_class => event.class)) unless event.respond_to?('labs')
    raise(I18n.translate('staged_message_is_already_assigned')) if self.state == self.class.states[:assigned]

    begin
      event.add_labs_from_staged_message(self)
    rescue StagedMessageError => assign_error
      self.state = self.class.states[:unprocessable]
      self.note = "#{self.note}\n\r[#{Time.now}] #{assign_error.message}"
      self.save!
      raise assign_error
    end

    self.state = self.class.states[:assigned]
    transaction do
      event.save!
      self.save!
    end
  end

  def assigned_event
    self.lab_results.first.try(:participation).try(:event)
  end

  def new_event_from(entity_id=nil)
    return nil if self.patient.patient_last_name.blank?

    event = MorbidityEvent.new(:workflow_state => 'new')

    if entity_id
      person = PersonEntity.find(entity_id.to_i)
      event.copy_from_person(person)
    else
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
    end

    event.build_jurisdiction unless event.jurisdiction
    event.jurisdiction.secondary_entity = (User.current_user.jurisdictions_for_privilege(:create_event).first || Place.unassigned_jurisdiction).entity
    event
  end

  def discard
    raise(I18n.translate('staged_message_is_already_assigned')) if self.state == self.class.states[:assigned]
    self.state = self.class.states[:discarded]
    self.save!
  end

  # Build an HL7 ACK^R01^ACK message in response to the received
  # ORU^R01^ORU_R01 message, indicating success or one or more error
  # conditions.
  def ack
    @ack ||= HL7::Message.new do |ack|
      orig_msh = message_header.msh_segment if message_header
      ack << HL7::Message::Segment::MSH.new do |msh|
        # MSH block setup

        msh.enc_chars = '^~&#'

        # msh.sending_app = ???
        # msh.sending_facility = ???

        # Are these correct?
        if orig_msh
          msh.recv_app      = orig_msh.sending_app
          msh.recv_facility = orig_msh.sending_facility
        end

        # YYYYMMDDHHMMSS+/-ZZZZ
        msh.time = DateTime.now.strftime("%Y%m%d%H%M%S%Z").sub(':', '')
        msh.message_type = 'ACK^R01^ACK'

        # Simple sequence number for now
        msh.message_control_id = self.class.next_sequence_number

        # msh.processing_id = ???

        msh.version_id = '2.5.1'

        # msh.accept_ack_type = ???
        # msh.app_ack_type = ???
        # msh.country_code = country_code_from_locale
        # msh.message_profile_identifier = ???
      end << HL7::Message::Segment::SFT.new do |sft|
        # SFT block setup

        sft.set_id = '1'

        # sft.software_vendor_organization = ???
        # sft.software_certified_version_or_release_number = ???

        sft.software_product_name = 'TriSano'

        # sft.software_binary_id = ???
        # sft.software_install_date = ???
      end << HL7::Message::Segment::MSA.new do |msa|
        # MSA block setup

        # consider also 'CR'?
        msa.ack_code = errors.size > 0 ? 'CE' : 'CA'
        msa.control_id = orig_msh.message_control_id if orig_msh
      end

      errors.each do |attribute, message|
        ack << HL7::Message::Segment::ERR.new do |err|
          # ERR block setup (looped)

          # err.error_location = where_this_error_occurred_in_the_message
          # err.hl7_error_code = ???
          # err.severity = ???

          err.diagnostic_information = message.to_s
          err.user_message = 'error processing message'

          # err.help_desk_contact_point = bug_report_address
        end
      end
    end
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

  def set_searchable_attributes
    self.patient_last_name =  self.patient.try :patient_last_name
    self.patient_first_name = self.patient.try :patient_first_name

    self.laboratory_name =    self.message_header.try :sending_facility
    unless observation_requests.empty?
      begin
        # TODO: Revise this.  Should #collection_date be replaced by a
        # method that returns an array of Dates?
        self.collection_date = Date.parse self.observation_requests.first.collection_date
      rescue
      end

      observation_requests.each do |observation_request|
        observation_request.tests.each do |test|
          self.staged_observations.build :test_type => test.test_type
        end
      end
    end
  end

  def self.next_sequence_number
    return @next_sequence_number = 1 unless @next_sequence_number
    @next_sequence_number += 1
  end
end
