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

class Code < ActiveRecord::Base

  def self.other_place_type_id
    safe_table_access do
      @@other_place_type ||= find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'")
      @@other_place_type.id unless @@other_place_type.nil?
    end
  end

  def self.telephone_location_type_id
    safe_table_access do
      @@telephone_location_type ||= find_by_code_name_and_the_code 'locationtype', 'TLT'
      @@telephone_location_type.id if @@telephone_location_type
    end
  end

  def self.address_location_type_id
    safe_table_access do
      @@address_location_type ||= find_by_code_name_and_the_code 'locationtype', 'ALT'
      @@address_location_type.id if @@address_location_type
    end
  end

  def self.interested_party
    safe_table_access do
      @@interested_party ||= Code.find_by_code_name_and_code_description('participant', 'Interested Party')
    end
  end

  def self.interested_party_id
    code = interested_party
    code.id if code
  end

  def self.jurisdiction_place_type_id
    safe_table_access do
      @@jurisdiction_place_type ||= Code.find_by_code_name_and_code_description('placetype', 'Jurisdiction')
      @@jurisdiction_place_type.id if @@jurisdiction_place_type
    end
  end

  def self.lab_place_type
    safe_table_access do
      @@lab_place_type ||= Code.find_by_code_name_and_the_code('placetype', 'L')
    end
  end

  def self.lab_place_type_id
    self.lab_place_type.id if self.lab_place_type
  end

  def self.primary_jurisdiction_participant_type_id
    safe_table_access do
      @@primary_jurisdiction_participant_type ||= Code.find_by_code_name_and_code_description('participant', "Jurisdiction")
      @@primary_jurisdiction_participant_type.id if @@primary_jurisdiction_participant_type
    end
  end

  def self.secondary_jurisdiction_participant_type_id
    safe_table_access do
      @@secondary_jurisdiction_participant_type ||= Code.find_by_code_name_and_code_description('participant', "Secondary Jurisdiction")
      @@secondary_jurisdiction_participant_type.id if @@secondary_jurisdiction_participant_type
    end
  end

  def self.tested_by_type_id
    safe_table_access do
      @@tested_by_type ||= Code.find_by_code_name_and_code_description('participant', "Tested By")
      @@tested_by_type.id if @@tested_by_type
    end
  end

  def self.hospitalized_at_type_id
    safe_table_access do
      @@hospitalized_at_type ||= find_by_code_name_and_code_description('participant', "Hospitalized At")
      @@hospitalized_at_type.id if @@hospitalized_at_type
    end
  end

  def self.diagnosed_at_type_id
    safe_table_access do
      @@diagnosed_at_type ||= find_by_code_name_and_code_description('participant', "Diagnosed At")
      @@diagnosed_at_type.id if @@diagnosed_at_type
    end
  end

  def self.treated_by_type_id
    safe_table_access do
      @@treated_by_type ||= find_by_code_name_and_code_description('participant', "Treated By")
      @@treated_by_type.id if @@treated_by_type
    end
  end

  def self.contact_type_id
    safe_table_access do
      @@contact_type ||= find_by_code_name_and_code_description('participant', "Contact")
      @@contact_type.id if @@contact_type
    end
  end

  def self.place_exposure_type_id
    safe_table_access do
      @@place_exposure_type ||= find_by_code_name_and_code_description('participant', 'Place Exposure')
      @@place_exposure_type.id if @@place_exposure_type
    end
  end

  def self.reporting_agency_type_id
    safe_table_access do
      @@reporting_agency_type ||= find_by_code_name_and_code_description('participant', "Reporting Agency")
      @@reporting_agency_type.id if @@reporting_agency_type
    end
  end

  def self.reported_by_type_id
    safe_table_access do 
      @@reported_by_type ||= find_by_code_name_and_code_description('participant', "Reported By")
      @@reported_by_type.id if @@reported_by_type
    end
  end

  def self.place_of_interest_type_id
    safe_table_access do
      @@place_of_interest_type ||= find_by_code_name_and_code_description('participant', "Place of Interest")
      @@place_of_interest_type.id if @@place_of_interest_type
    end
  end

  private
  
  def self.safe_table_access
    begin
      return yield if block_given?
    rescue
      logger.error "Error reading from the codes table. This sometimes happens when running rake"
    ensure
      nil
    end
  end
end
