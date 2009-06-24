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

require 'ruby-hl7'

module HL7
  class Message

    def message_header
      self[:MSH] ? StagedMessages::MshWrapper.new(self[:MSH]) : nil
    end

    def patient_id
      self[:PID] ? StagedMessages::PidWrapper.new(self[:PID]) : nil
    end

    def observation_request
      self[:OBR] ? StagedMessages::ObrWrapper.new(self[:OBR].is_a?(Array) ? self[:OBR][0] : self[:OBR]) : nil
    end

  end
end

module StagedMessages
  class MshWrapper
    attr_reader :msh_segment

    def initialize(msh_segment)
      @msh_segment = msh_segment
    end

    def sending_facility
      begin
        msh_segment.sending_facility.split(msh_segment.item_delim).first
      rescue
        "Could not be determined"
      end
    end
  end

  class PidWrapper
    def initialize(pid_segment)
      @pid_segment = pid_segment
    end

    attr_reader :pid_segment

    def name_components
      @name_componets ||= pid_segment.patient_name.split(pid_segment.item_delim)
    end

    def addr_components
      @addr_components ||= pid_segment.address.split(pid_segment.item_delim)
    end

    # Ultimately we should make a patient class that has all the components as attributes
    def patient_name
      begin
        name = patient_last_name || "No Last Name"
        name += ", #{patient_first_name}" unless patient_first_name.blank?
        name += " #{patient_middle_name}" unless patient_middle_name.blank?
        name += ", #{patient_suffix}" unless patient_suffix.blank?
        name
      rescue
        "Could not be determined"
      end
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
      begin
        return nil if pid_segment.patient_dob.blank?
        Date.parse(pid_segment.patient_dob)
      rescue
        "Could not be determined"
      end
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
      race_id = nil
      if race_md = /^[WBAIHKU]$/.match(pid_segment.race.split(pid_segment.item_delim)[0])
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
        race_object = ExternalCode.find_by_code_name_and_the_code('race', race)
        race_id = race_object.id if race_object
      end
      race_id
    end

    def address_empty?
      components_empty?(addr_components)
    end

    def address_street_no
      if unit_md = /^\w+ /.match(addr_components[0])
        unit_md[0].strip
      else
        unit_md
      end
    end

    def address_unit_no
      addr_components[1].titleize
    end

    def address_street
      if md = /^\w+ /.match(addr_components[0])
        md.post_match.titleize
      else
        md
      end
    end

    def address_city
      addr_components[2].titleize
    end

    def address_trisano_state_id
      unless addr_components[3].blank?
        state_object = ExternalCode.find_by_code_name_and_the_code('state', addr_components[3])
        state_object.id if state_object
      else
        nil
      end
    end

    def address_zip
      addr_components[4]
    end

    def telephone_empty?
      components_empty?(self.pid_segment.phone_home.split(pid_segment.item_delim))
    end

    def telephone_home
      phone_components = self.pid_segment.phone_home.split(pid_segment.item_delim)
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

    private

    def components_empty?(components)
      components.all? { |comp| comp.empty? }
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
      obr_segment.universal_service_id.split(obr_segment.item_delim)[1]
    end

    def specimen_source
      obr_segment.specimen_source.split('^').join(', ')
    end
  
    def collection_date
      begin
        return nil if obr_segment.observation_date.blank?
        Date.parse(obr_segment.observation_date).to_s
      rescue
        "Could not be determined"
      end
    end

    def tests
      obr_segment.children.collect { |s| StagedMessages::ObxWrapper.new(s) }
    end
  end

  class ObxWrapper
    attr_reader :obx_segment
    
    def initialize(obx_segment)
      @obx_segment = obx_segment
    end

    def observation_date
      begin
        return nil if obx_segment.observation_date.blank?
        Date.parse(obx_segment.observation_date).to_s
      rescue
        "Could not be determined"
      end
    end

    def result
      begin
        obx_segment.observation_value.split(obx_segment.item_delim).join(' ') + (obx_segment.units.blank? ? '' : " #{obx_segment.units}")
      rescue
        "Could not be determined"
      end
    end
  
    def reference_range
      begin
        obx_segment.references_range
      rescue
        "Could not be determined"
      end
    end

    def test_type
      begin
        obx_segment.observation_id.split(obx_segment.item_delim)[1]
      rescue
        "Could not be determined"
      end
    end
  end
end
