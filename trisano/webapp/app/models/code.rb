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

class Code < ActiveRecord::Base

  def self.other_place_type_id
   code = find(:first, :conditions => "code_name = 'placetype' and the_code = 'O'")
   code.id unless code.nil?
  end

  def self.telephone_location_type_id
    code = find_by_code_name_and_the_code 'locationtype', 'TLT'
    code.id if code
  end

  def self.address_location_type_id
    code = find_by_code_name_and_the_code 'locationtype', 'ALT'
    code.id if code
  end

  def self.interested_party
    Code.find_by_code_name_and_code_description('participant', 'Interested Party')
  end

  def self.interested_party_id
    code = interested_party
    code.id if code
  end

  def self.jurisdiction_place_type_id
    code = Code.find_by_code_name_and_code_description('placetype', 'Jurisdiction')
    code.id if code
  end

  def self.primary_jurisdiction_participant_type_id
    code = Code.find_by_code_name_and_code_description('participant', "Jurisdiction")
    code.id if code
  end

  def self.secondary_jurisdiction_participant_type_id
    code = Code.find_by_code_name_and_code_description('participant', "Secondary Jurisdiction")
    code.id if code
  end

  def self.tested_by_type_id
    code = Code.find_by_code_name_and_code_description('participant', "Tested By")
    code.id if code
  end

  def self.hospitalized_at_type_id
    code = find_by_code_name_and_code_description('participant', "Hospitalized At")
    code.id if code
  end

  def self.diagnosed_at_type_id
    code = find_by_code_name_and_code_description('participant', "Diagnosed At")
    code.id if code
  end

  def self.treated_by_type_id
    code = find_by_code_name_and_code_description('participant', "Treated By")
    code.id if code    
  end

  def self.contact_type_id
    code = find_by_code_name_and_code_description('participant', "Contact")
    code.id if code
  end

  def self.place_exposure_type_id
    code = find_by_code_name_and_code_description('participant', 'Place Exposure')
    code.id if code
  end

  def self.reporting_agency_type_id
    code = find_by_code_name_and_code_description('participant', "Reporting Agency")
    code.id if code
  end

  def self.reported_by_type_id
    code = find_by_code_name_and_code_description('participant', "Reported By")
    code.id if code
  end
end
