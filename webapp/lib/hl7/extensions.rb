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
    attr_reader :pid_segment

    def initialize(pid_segment)
      @pid_segment = pid_segment
    end

    # Ultimately we should make a patient class that has all the components as attributes
    def patient_name
      begin
        name_components = pid_segment.patient_name.split(pid_segment.item_delim)
        name = name_components[0] || "No Last Name"
        name += ", #{name_components[1]}" unless name_components[1].blank?  # first name
        name += " #{name_components[2]}" unless name_components[2].blank?   # midlle name or initial
        name += ", #{name_components[3]}" unless name_components[3].blank?  # suffix, e.g. Jr. or III
        name
      rescue
        "Could not be determined"
      end
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
        Date.parse(obx_segment.observation_date).to_s
      rescue
        "Could not be determined"
      end
    end

    def result
      begin
        obx_segment.observation_value + (obx_segment.units.blank? ? '' : " #{obx_segment.units}")
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
