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

  def self.jurisdiction_place_type_id
    code = Code.find_by_code_name_and_code_description('placetype', 'Jurisdiction')
    code.id if code
  end

end
