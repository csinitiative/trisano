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
      add_hl7_error :parse_error
      return
    end

    add_hl7_error(:missing_header, :msh, 1) if message_header.nil?

    if patient.nil?
      add_hl7_error :missing_segment, :pid, 1
      return
    end

    if observation_requests.empty?
      add_hl7_error :missing_segment, :obr, 1
    end

    # error in PID segment, set ID 1 (only one PID), field 5, component 1
    add_hl7_error(:missing_last_name, :pid, 1, 5, 1) if self.patient.patient_last_name.blank?

    observation_requests.each do |obr|
      obr.all_tests.each do |test|
        # error in OBX segment with set_id, field 3, component 1
        add_hl7_error(:missing_loinc, :obx, test.set_id, 3, 1) if test.loinc_code.blank?
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
    @ack ||= HL7::Message.new do |a|
      a << ack_msh << ack_sft << ack_msa

      @hl7_errs.each { |e| a << self.class.ack_err(*e) } if @hl7_errs
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

  def orig_msh
    @orig_msh ||= message_header.msh_segment if message_header
  end

  def ack_msh
    @ack_msh ||= HL7::Message::Segment::MSH.new do |msh|
      # literal constants
      msh.enc_chars       = '^~&#'
      msh.version_id      = '2.5.1'
      msh.accept_ack_type = 'AL'
      msh.app_ack_type    = 'AL'

      # In the event we ever use a different component delimiter,
      # these literals will come out correctly by using the join
      # method (instead, e.g., of using 'ACK^R01^ACK').
      msh.message_type = %w{ACK R01 ACK}.join(msh.item_delim)
      msh.message_profile_identifier = [ 'PHLabReport-Ack', '',
        '2.16.840.1.114222.4.10.3', 'ISO' ].join(msh.item_delim)

      # current time: YYYYMMDDHHMMSS+/-ZZZZ
      msh.time = DateTime.now.strftime("%Y%m%d%H%M%S%Z").sub(':', '')

      # P^ => production, current processing (needs to be configurable)
      msh.processing_id = [ 'P', '' ].join(msh.item_delim)

      if orig_msh
        msh.sending_app      = orig_msh.sending_app
        msh.sending_facility = orig_msh.sending_facility
      end

      # Simple sequence number for now, might need to be a UUID
      msh.message_control_id = self.class.next_sequence_number

      # The next two fields are required
      # ================================

      # TODO: Determine CE/EE programmatically
      trisano_oid = %w{csi-trisano-ce 2.16.840.1.113883.4.434 ISO}
      # trisano_oid = %w{csi-trisano-ee 2.16.840.1.113883.4.435 ISO}
      msh.recv_app = trisano_oid.join(msh.item_delim)

      # Refers to the facility running TriSano; needs to be
      # configurable.
      # msh.recv_facility = ???

      # country code is optional in an ACK^R01^ACK message
      # msh.country_code = country_code_from_locale
    end
  end

  def ack_sft
    @ack_sft ||= HL7::Message::Segment::SFT.new do |sft|
      sft.set_id = '1'

      # results in 'CSI^D' : CSI is the organization name; it is a display
      # name (as oppposed to a legal name, alias, etc.)
      sft.software_vendor_organization = %w{CSI D}.join(sft.item_delim)

      # sft.software_certified_version_or_release_number = ???

      sft.software_product_name = 'TriSano'

      # sft.software_binary_id = ???
      # sft.software_install_date = ???
    end
  end

  def ack_msa
    @ack_msa ||= HL7::Message::Segment::MSA.new do |msa|
      # consider also 'CE'?
      msa.ack_code = errors.size > 0 ? 'CR' : 'CA'
      msa.control_id = orig_msh.message_control_id if orig_msh
    end
  end

  def add_hl7_error(*args)
    trisano_code, segment_name, set_id, field_number, component_number,
      subcomponent_number = *args
    trisano_code = trisano_code.to_sym

    # Error text from Rails
    error_text = case trisano_code
    when :missing_loinc
      errors.add :hl7_message, :missing_loinc, :segment => set_id.to_i
    else
      errors.add :hl7_message, trisano_code
    end.last

    # Map to a known HL7 code
    hl7_code = case trisano_code
    when :missing_loinc, :missing_last_name
      :required_field_missing
    when :missing_segment, :missing_header
      :segment_sequence_error
    else
      :application_internal_error
    end

    # Save all this info
    @hl7_errs ||= []
    @hl7_errs << [ trisano_code, hl7_code, error_text, segment_name,
      set_id, field_number, component_number, subcomponent_number ]
  end

  class << self
    def next_sequence_number
      @last_sequence_number += 1
    end

    def ack_err(*args)
      trisano_code, hl7_code, error_text, rest = *args
      HL7::Message::Segment::ERR.new do |err|
        err.error_location = hl7_error_location(*args).join(err.item_delim)
        err.hl7_error_code = hl7_error_code(hl7_code).join(err.item_delim)
        err.severity = 'E'
        err.diagnostic_information = error_text.to_s
        err.user_message = 'error processing message'

        # "NET^Internet^#{bug_report_address}"
        # err.help_desk_contact_point = [ 'NET', 'Internet', bug_report_address ].join(err.item_delim)
      end
    end

    # Returns an array [ error_number, error_string, 'HL70357' ]
    # DEBT: Move this to lib/hl7/extensions.rb
    def hl7_error_code(hl7_code)
      @hl7_error_codes ||=
        {
          # From table HL70357
          :segment_sequence_error     => 100,
          :required_field_missing     => 101,
          :data_type_error            => 102,
          :table_value_not_found      => 103,
          :unsupported_message_type   => 200,
          :unsupported_event_code     => 201,
          :unsupported_processing_id  => 202,
          :unsupported_version_id     => 203,
          :unknown_key_identifier     => 204,
          :duplicate_key_identifier   => 205,
          :application_record_locked  => 206,
          :application_internal_error => 207
        }

      [ @hl7_error_codes[hl7_code], hl7_code.to_s.gsub('_', ' '),
        'HL70357' ]
    end

    # Returns an array
    # [ 'SEG', set_id, field_number, component_number, subcomponent_number ]
    # All entries are strings.  The array terminates as soon as a
    # component is missing.  (For example, if there's no field number,
    # there won't be a subcomponent number either.)
    # DEBT: Move this to lib/hl7/extensions.rb
    def hl7_error_location(*args)
      trisano_code, hl7_code, error_text, segment_name, set_id,
        field_number, component_number, subcomponent_number = *args

      return [ '' ] unless segment_name
      erl = [ segment_name.to_s.upcase ]

      return erl unless set_id
      erl << [ set_id.to_s ]

      return erl unless field_number
      erl << [ field_number.to_s ]

      return erl unless component_number
      erl << [ component_number.to_s ]

      return erl unless subcomponent_number
      erl << [ subcomponent_number.to_s ]
    end
  end

  @last_sequence_number = 0
end
