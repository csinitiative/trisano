# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

require 'ruby-hl7'

######## Extensions to the ruby-hl7 gem
module HL7
  class Message
    def message_header
      @message_header = self[:MSH] ? StagedMessages::MshWrapper.new(self[:MSH]) : nil
    end

    def patient_id
      @patient_id = self[:PID] ? StagedMessages::PidWrapper.new(self[:PID]) : nil
    end

    def next_of_kin
      @next_of_kin = self[:NK1] ? StagedMessages::Nk1Wrapper.new(self[:NK1]) : nil
    end

    def common_order
      @common_order = self[:ORC] ? StagedMessages::OrcWrapper.new(self[:ORC]) : nil
    end

    def pv1
      @pv1 = self[:PV1] ? StagedMessages::Pv1Wrapper.new(self[:PV1]) : nil
    end

    def pv2
      @pv2 = self[:PV2] ? StagedMessages::Pv2Wrapper.new(self[:PV2]) : nil
    end

    # Return an array of ObrWrapper objects corresponding to the OBR
    # segments of the HL7 message.  If no OBR segment is present, an
    # empty array is returned.
    def observation_requests
      @obr_segments ||= case (obr_segments=self[:OBR])
      when Array
        obr_segments.map { |s| StagedMessages::ObrWrapper.new s }
      when nil
        []
      else
        [ StagedMessages::ObrWrapper.new obr_segments ]
      end
    end

    def version_id
      message_header.version_id if message_header
    end

    def enhanced_ack_mode?
      message_header.enhanced_ack_mode?
    end
  end
end

class HL7::Message::Segment
  def collect_children(child_type)
    seg_name = child_type.to_s
    raise HL7::Exception, "invalid child type #{seg_name}" unless
      accepts? child_type.to_sym

    hl7_klass = eval("HL7::Message::Segment::%s" % seg_name.upcase)
    sm_klass = eval("StagedMessages::%sWrapper" % seg_name.capitalize)

    children.inject([]) do |t, s|
      t << sm_klass.new(s) if s.is_a? hl7_klass
      t
    end
  end
end

####### Classes for parsing certain data types

module StagedMessages

  class MshWrapper
    attr_reader :msh_segment

    def initialize(msh_segment)
      @msh_segment = msh_segment
    end

    def sending_facility
      msh_segment.sending_facility.split(msh_segment.item_delim).first
    rescue
      "Could not be determined"
    end

    def time
      Time.parse(msh_segment.time) unless msh_segment.time.blank?
    end

    # Should be '2.5.1' or something similar for other versions.
    def version_id
      msh_segment.version_id
    end

    def enhanced_ack_mode?
      not msh_segment.accept_ack_type.blank? and not msh_segment.app_ack_type.blank?
    end

    def software_segments
      @software_segments ||= msh_segment.collect_children(:SFT)
    end
  end

  class PidWrapper
    def initialize(pid_segment)
      @pid_segment = pid_segment
    end

    attr_reader :pid_segment

    def name_components
      @name_components ||= (pid_segment.patient_name || "").split(pid_segment.item_delim)
    end

    def addr_components
      @addr_components ||= (pid_segment.address || "").split(pid_segment.item_delim)
    end

    # Ultimately we should make a patient class that has all the components as attributes
    def patient_name
      name = patient_last_name || "No Last Name"
      name += ", #{patient_first_name}" unless patient_first_name.blank?
      name += " #{patient_middle_name}" unless patient_middle_name.blank?
      name += ", #{patient_suffix}" unless patient_suffix.blank?
      name
    rescue
      "Could not be determined"
    end

    def patient_last_name
      name = name_components[0].try(:humanize)
    end

    def patient_first_name
      name = name_components[1].try(:humanize)
    end

    def patient_middle_name
      name = name_components[2].try(:humanize)
    end

    def patient_suffix
      name = name_components[3]
    end

    def birth_date
      return nil if pid_segment.patient_dob.blank?
      Date.parse(pid_segment.patient_dob)
    rescue
      "Could not be determined"
    end

    def death_date
      Date.parse(pid_segment.death_date)
    rescue
    end

    # This returns the actual PID-30 value, not a boolean, so I'm not
    # calling it dead? or died?  It will be mapped to that in the app
    # code.
    def dead_flag
      pid_segment.death_indicator
    rescue
    end

    def trisano_sex_id
      sex_id = nil

      begin
        elr_sex = pid_segment.admin_sex
      rescue HL7::InvalidDataError
        return sex_id
      end

      if sex_md = /^[FMU]$/.match(elr_sex)
        sex = sex_md[0]
        sex = 'UNK' if sex == 'U'
        sex_object = ExternalCode.find_by_code_name_and_the_code('gender', sex)
        sex_id = sex_object.id if sex_object
      end
      sex_id
    end

    def trisano_race_id
      race, race_id = nil, nil
      elr_race_code = (pid_segment.race || "U").split(pid_segment.item_delim)[0]
      if race_md = /^[WBAIHKU]$/.match(elr_race_code)
        race = race_md[0]
        race = case race
               when 'I'
                 'AA'
               when 'K'
                 'AK'
               when 'U'
                 'UNK'
               else
                 race
               end
      elsif race_md = /^(\d+-\d)$/.match(elr_race_code)
        race = race_md[0]
        race = case race
               when '1002-5' # American Indian or Alaska Native
                 return aa_and_ak_race_ids
               when '2028-9' # Asian
                 'A'
               when '2054-5' # Black or African American
                 'B'
               when '2076-8' # Native Hawaiian or Other Pacific Islander
                 'H'
               when '2106-3' # White
                 'W'
               when '2131-1' # Other Race
                 'OTHER'
               else
                 'UNK'
               end
      end
      race_object = ExternalCode.find_by_code_name_and_the_code('race', race)
      race_id = race_object.id if race_object
      race_id
    end

    def trisano_ethnicity_id
      elr_ethnicity_code = pid_segment.ethnic_group.split(pid_segment.item_delim).first
      ethnicity = case elr_ethnicity_code
      when 'H'
        'H'
      when 'N'
        'NH'
      when 'U'
        'UNK'
      else
      end
      ethnicity_object = ExternalCode.find_by_code_name_and_the_code('ethnicity', ethnicity) if ethnicity
      ethnicity_object.id if ethnicity_object
    rescue
    end

    def primary_language
      returning pid_segment.primary_language.split(pid_segment.item_delim).first do |iso_code|
        def iso_code.id
          external_code = ExternalCode.first :conditions => [ "code_name = 'language' AND the_code ~* ?", '^'+self+'$' ]
          external_code.id if external_code
        end unless iso_code.nil?
      end
    rescue
    end

    def address_empty?
      components_empty?(addr_components)
    end

    def address_street_no
      if unit_md = /^[\w-]+ /.match(addr_components[0])
        unit_md[0].strip
      else
        unit_md
      end
    end

    def address_unit_no
      (addr_components[1] || "").titleize
    end

    def address_street
      if md = /^[\w-]+ /.match(addr_components[0])
        md.post_match.titleize
      else
        md
      end
    end

    def address_city
      (addr_components[2] || "").titleize
    end

    def address_trisano_state_id
      unless addr_components[3].blank?
        state_object = ExternalCode.find_by_code_name_and_the_code('state', addr_components[3])
        if state_object
          state_object.id
        else
          # case-insensitive search
          state_object = ExternalCode.first :conditions => [ "code_name = 'state' AND code_description ~* ?", '^'+addr_components[3]+'$' ]
          state_object.id if state_object
        end
      else
        nil
      end
    end

    def address_zip
      addr_components[4]
    end

    # returns a string for use in the lab notes
    def address_country
      addr_components[5] if addr_components
    end

    def address_county
      addr_components[8] if addr_components
    end

    def telephone_type_home
      ExternalCode.find_by_code_name_and_the_code 'telephonelocationtype',
        case pid_segment.phone_home.split(pid_segment.item_delim).third
        when 'PH'
          'HT'
        when 'CP'
          'MT'
        when 'BP'
          'PAGE'
        else
          'UNK'
        end
    end

    def telephone_empty?
      components_empty?(self.pid_segment.phone_home.split(pid_segment.item_delim))
    rescue
      true
    end

    def telephone_home
      phone_components = pid_segment.phone_home.split(pid_segment.item_delim)
      split_phone phone_components
    rescue
      []
    end

    def telephone_type_work
      ExternalCode.find_by_code_name_and_the_code 'telephonelocationtype',
        case pid_segment.phone_business.split(pid_segment.item_delim).third
        when 'PH'
          'WT'
        when 'CP'
          'MT'
        when 'BP'
          'PAGE'
        else
          'UNK'
        end
    end

    def telephone_work
      phone_components = pid_segment.phone_business.split(pid_segment.item_delim)
      split_phone phone_components
    rescue
      []
    end

    def telephone_work_empty?
      components_empty?(pid_segment.phone_business.split(pid_segment.item_delim))
    rescue
      true
    end

    def notes
      @notes ||= pid_segment.collect_children(:NTE)
    end

    def visit1
      pid_segment.collect_children(:PV1).first
    end

    def visit2
      pid_segment.collect_children(:PV2).first
    end

    private

    def split_phone(phone_components)
      area_code = number = extension = nil
      unless phone_components[0].blank?
        area_code, number, extension = Utilities.parse_phone(phone_components[0])
      else
        area_code = phone_components[5]
        number = phone_components[6]
        extension = phone_components[7]
      end
      return area_code, number, extension
    end

    def components_empty?(components)
      components.all? { |comp| comp.empty? }
    end

    def aa_and_ak_race_ids
      # In the unlikely event of a badly misconfigured system, it's
      # possible for one of these lookups to fail.  We use inject to
      # allow for the possibility of having 0 or 1 successful matches.
      # Ordinarily this array will return an array of two Fixnums.
      %w{AA AK}.inject([]) do |ids, race_code|
        xcode = ExternalCode.find_by_code_name_and_the_code('race', race_code)
        ids << xcode.id if xcode
        ids
      end
    end
  end

  class Nk1Wrapper
    attr_reader :nk1_segment

    def initialize(nk1_segment, options={})
      @nk1_segment = nk1_segment
    end

    # Returns the NK1-2 components as an array if the relationship is
    # parent or guardian, i.e.
    # last, first, middle, suffix, prefix, degree, name type code, etc.
    def parent_guardian
      case nk1_segment.relationship.split(nk1_segment.item_delim).first
      when 'FTH','GRD','MTH','PAR'
        nk1_segment.name.split nk1_segment.item_delim
      else
        []
      end
    rescue
      []
    end
  end

  class OrcWrapper
    attr_reader :orc_segment

    def initialize(orc_segment, options={})
      @orc_segment = orc_segment
    end

    def clinician_first_name
      clinician_name_components.third
    rescue
    end

    def clinician_last_name
      clinician_name_components.second
    rescue
    end

    def clinician_phone_type
      ExternalCode.find_by_code_name_and_the_code 'telephonelocationtype',
        case clinician_phone_components.third
        when 'PH'
          'WT'
        when 'CP'
          'MT'
        when 'BP'
          'PAGE'
        else
          'UNK'
        end
    rescue
    end

    def clinician_telephone
      area_code = number = extension = nil
      unless clinician_phone_components[0].blank?
        area_code, number, extension = Utilities.parse_phone(clinician_phone_components[0])
      else
        area_code = clinician_phone_components[5]
        number = clinician_phone_components[6]
        extension = clinician_phone_components[7]
      end
      return area_code, number, extension
    rescue
    end

    def facility_name
      orc_segment.ordering_facility_name.split(orc_segment.item_delim).first
    rescue
    end

    def components_empty?(components)
      components.all? { |comp| comp.empty? }
    end

    def facility_addr_components
      @facility_addr_components ||= orc_segment.ordering_facility_address.split(orc_segment.item_delim)
     end

    def facility_address_empty?
      components_empty?(facility_addr_components)
    end

    def facility_address_street_no
      if unit_md = /^\w+ /.match(facility_addr_components[0])
        unit_md[0].strip
      else
        unit_md
      end
    end

    def facility_address_street
      if md = /^\w+ /.match(facility_addr_components[0])
        md.post_match.titleize
      else
        md
      end
    end

    def facility_address_city
      (facility_addr_components[2] || "").titleize
    end

    def facility_address_trisano_state_id
      if !facility_addr_components[3].blank?
        state_object = ExternalCode.find_by_code_name_and_the_code('state', facility_addr_components[3])
        state_object ||= ExternalCode.first :conditions => [ "code_name = 'state' AND code_description ~* ?", '^'+ facility_addr_components[3]+'$' ]
        state_object.id if state_object
      end
    end

    def facility_address_zip
      facility_addr_components[4]
    end

    def facility_address_country
      facility_addr_components[5] if facility_addr_components
    end

    private

    def clinician_name_components
      orc_segment.ordering_provider.split(orc_segment.item_delim)
    end

    def clinician_phone_components
      orc_segment.call_back_phone_number.split(orc_segment.item_delim)
    end
  end

  class ObrWrapper
    attr_reader :obr_segment
    attr_accessor :full_message

    def initialize(obr_segment, options={})
      @obr_segment = obr_segment
      @full_message = options[:full_message]
    end

    def test_performed
      obr_segment.universal_service_id.split(obr_segment.item_delim)[0]
    rescue
      ''
    end

    def common_test_type
      test_type = obr_segment.universal_service_id.split(obr_segment.item_delim)[1] if obr_segment.universal_service_id
      test_type || LoincCode.find_by_loinc_code(test_performed).common_test_type.common_name
    rescue
      ''
    end

    def specimen_source
      returning specimen_source_2_5_1 || specimen_source_2_3_1 do |source|
        def source.id
          ExternalCode.find(
            :first,
            :select => 'id',
            :conditions => ["code_name = 'specimen' AND code_description ~* ?", '^'+self+'$']
          ).try(:id)
        end
      end
    end

    # Take the specimen source from SPM-4
    # Returns +nil+ if no SPM segment.
    def specimen_source_2_5_1
      return nil unless spm_segment

      specimen_source = spm_segment.specimen_source_site
      specimen_source = spm_segment.specimen_type if specimen_source.blank?

      return nil if specimen_source.blank?

      # The second delimited field is the name of the specimen
      specimen_source.split(spm_segment.item_delim).second
    end

    # Take the specimen source from OBR-15
    def specimen_source_2_3_1
      obr_segment.specimen_source.split(obr_segment.item_delim).join(', ')
    end

    def collection_date
      return Date.parse(obr_segment.observation_date).to_s unless
        obr_segment.observation_date.blank?

      all_tests.each do |obx|
        return obx.observation_date if obx.observation_date
      end

      specimen.collection_date if specimen

      Date.parse(obr_segment.requested_date).to_s unless obr_segment.requested_date.blank?
    rescue
      "Could not be determined"
    end

    def all_tests
      return tests unless specimen and specimen.tests
      return specimen.tests unless tests
      tests + specimen.tests
    end

    def tests
      @tests ||= obr_segment.collect_children(:OBX)
    end

    def notes
      @notes ||= obr_segment.collect_children(:NTE)
    end

    # Though the HL7 2.5.1 spec provides for multiple SPM segments per
    # OBR segment, TriSano currently only handles one.
    #
    # This method returns the first SPM segment associated with this
    # OBR segment (+nil+ if none).
    def specimen
      @specimen ||= obr_segment.collect_children(:SPM).first
    end

    def spm_segment
      specimen.spm_segment if specimen
    end

    def filler_order_number
      obr_segment.filler_order_number.split(obr_segment.item_delim).first if obr_segment.filler_order_number
    rescue
    end

    def specimen_id
      spm_segment.specimen_id.split(spm_segment.item_delim).first.split('&').first if spm_segment.specimen_id
    rescue
    end

    def result_status
      obr_segment.result_status
    rescue
    end

    def clinician_first_name
      clinician_name_components.third
    rescue
    end

    def clinician_last_name
      clinician_name_components.second
    rescue
    end

    def clinician_phone_type
      ExternalCode.find_by_code_name_and_the_code 'telephonelocationtype',
        case clinician_phone_components.third
        when 'PH'
          'WT'
        when 'CP'
          'MT'
        when 'BP'
          'PAGE'
        else
          'UNK'
        end
    rescue
    end

    def clinician_telephone
      area_code = number = extension = nil
      unless clinician_phone_components[0].blank?
        area_code, number, extension = Utilities.parse_phone(clinician_phone_components[0])
      else
        area_code = clinician_phone_components[5]
        number = clinician_phone_components[6]
        extension = clinician_phone_components[7]
      end
      return area_code, number, extension
    rescue
    end

    private

    def clinician_name_components
      obr_segment.ordering_provider.split(obr_segment.item_delim)
    end

    def clinician_phone_components
      obr_segment.order_callback_phone_number.split(obr_segment.item_delim)
    end
  end

  class ObxWrapper
    attr_reader :obx_segment

    def initialize(obx_segment)
      @obx_segment = obx_segment
    end

    def notes
      @notes ||= obx_segment.collect_children(:NTE)
    end

    def set_id
      return nil if obx_segment.observation_date.blank?
      obx_segment.set_id
    rescue
      "Could not be determined"
    end

    def test_date
      analysis_date || observation_date
    end

    def test_performed
      obx_segment.observation_sub_id.split(obx_segment.item_delim)[0]
    end

    def observation_date
      Date.parse(obx_segment.observation_date).to_s unless obx_segment.observation_date.blank?
    rescue
      "Could not be determined"
    end

    def analysis_date
      Date.parse(obx_segment.analysis_date).to_s unless obx_segment.analysis_date.blank?
    rescue
      "Could not be determined"
    end

    def result
      value_type = obx_segment.value_type

      klass = case value_type
      when 'CE', 'CWE', 'SN'
        eval value_type
      else
        Default
      end

      klass.new(obx_segment.observation_value, obx_segment.item_delim).to_s
    rescue
      "Could not be determined"
    end

    def units
      obx_segment.units.split(obx_segment.item_delim)[0]
    rescue
      "Could not be determined"
    end

    def reference_range
      obx_segment.references_range
    rescue
      "Could not be determined"
    end

    def loinc_code
      obx_segment.observation_id.split(obx_segment.item_delim)[0]
    rescue
      "Could not be determined"
    end

    def test_type
      loinc_text_segments[0]
    rescue
      "Could not be determined"
    end

    # To determine the scale (Nom, Ord, OrdQn, Qn) associated with the
    # loinc_code, we consult these sources, in order:
    # 1. LoincCode.find_by_loinc_code (consult TriSano table)
    # 2. StagedMessage::ObxWrapper#loinc_scale
    #    a. loinc_text_segments[4] (the fifth subcomponent of the CWE.2
    #       component of the OBX-3 field, if present)
    #    b. Consult OBX-2 (value type):
    #       'NM' => 'Qn' # numeric
    #    c. nil (punt, can't process this OBX segment)
    def loinc_scale
      scale = loinc_text_segments[4]
      raise "LOINC scale not in CWE.2" if scale.nil? or scale.empty?
      scale
    rescue
      case obx_segment.value_type
      when 'NM'
        'Qn'
      end
    end

    def loinc_common_test_type
      loinc_text_segments[5]
    rescue
    end

    def status
      obx_segment.observation_result_status
    rescue
      "Could not be determined"
    end

    def trisano_status_id
      # I'm being ultra-lean (aka lazy) here and hard coding these until there's a story
      # that says that admins should be able to dynamically map them.
      hl7_status_codes = { 'C' => 'F', 'F' => 'F', 'I' => 'I', 'P' => 'P', 'R' => 'P', 'S' => 'P' }

      elr_result_status = obx_segment.segment_parent.result_status
      elr_result_status = self.status.upcase if elr_result_status.blank?
      return nil unless hl7_status_codes.has_key?(elr_result_status)
      status = ExternalCode.find_by_code_name_and_the_code('test_status', hl7_status_codes[elr_result_status])
      status ? status.id : status
    end

    def abnormal_flags
      obx_segment.abnormal_flags.split(obx_segment.item_delim).first if obx_segment.abnormal_flags
    rescue
    end

    private

    def loinc_text_segments
      # The layout of an OBX-3 field with a LOINC code is
      #
      # <code>^<text>^LN^^^^<loinc_version>
      #
      # LN indicates that it is a LOINC code.

      # For example, (from the Realm Campylobacter jejuni message,
      # section 7.2, p. 186):
      #
      # 625-4^Bacteria identified:Prid:Pt:Stool:Nom:Culture^LN^^^^2.26

      # In this example, the text component also has a colon-delimited
      # substructure.  The OBX-3 field is of type CWE.  The CWE.2
      # component (text) is of type ST, a simple string.  The HL7 spec
      # does not provide for this field to have a substructure and does
      # not recognize the colon (:) as a subcomponent delimiter
      # character.  But empirically, we find that in some cases, the
      # LOINC description includes, among other things, the associated
      # scale (Nom in this example).  We make use of this information
      # in cases in which the LOINC code in the first component cannot
      # be mapped.  This method returns the text subcomponents as an
      # array of strings.

      loinc_components = obx_segment.observation_id.split(obx_segment.item_delim)
      loinc_components[1].split(':') if loinc_components[2] == 'LN'
    end

    class Default
      attr_reader :field
      attr_reader :delim

      def initialize(field, delim)
        @field = field
        @delim = delim
      end

      def to_s
        field
      end
    end

    class CE < Default
      def to_s
        components = field.split(delim)
        components[4].blank? ? components[1] : components[4]
      end
    end

    # code^text^...
    class CWE < Default
      def to_s
        field.split(delim)[1]
      end
    end

    class SN < Default
      def to_s
        field.gsub delim, ' '
      end
    end
  end

  class SpmWrapper
    attr_reader :spm_segment

    def initialize(spm_segment)
      @spm_segment = spm_segment
    end

    # Returns an Array of StagedMessages::ObxWrapper objects
    # corresponding to OBX segments associated with this SPM segment.
    # Returns an empty array if none.
    def tests
      @tests ||= spm_segment.collect_children(:OBX)
    end

    def collection_date
      Date.parse(spm_segment.specimen_collection_date).to_s if
        spm_segment and spm_segment.specimen_collection_date
    rescue
    end
  end

  class NteWrapper
    attr_reader :nte_segment

    def initialize(nte_segment)
      @nte_segment = nte_segment
    end
  end

  class Pv1Wrapper
    attr_reader :pv1_segment

    def initialize(pv1_segment)
      @pv1_segment = pv1_segment
    end

    # Returns an array [ last_name, first_name ]
    def attending_doctor
      pv1_segment.attending_doctor.split(pv1_segment.item_delim).slice(1,2)
    rescue
      []
    end

    # Returns an array [ last_name, first_name ]
    def consulting_doctor
      pv1_segment.consulting_doctor.split(pv1_segment.item_delim).slice(1,2)
    rescue
      []
    end

    def hospitalized_id
      case pv1_segment.patient_class
      when 'I'
        ExternalCode.yes.id
      when 'O'
        ExternalCode.no.id
      else
      end
    rescue
    end
  end

  class Pv2Wrapper
    attr_reader :pv2_segment

    def initialize(pv2_segment)
      @pv2_segment = pv2_segment
    end

    def facility_name
      pv2_segment.clinic_organization_name.split(pv2_segment.item_delim).first
    rescue
    end
  end
end
