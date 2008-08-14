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

class Address < ActiveRecord::Base
  belongs_to :location
  belongs_to :county, :class_name => 'ExternalCode'
  belongs_to :district, :class_name => 'ExternalCode'
  belongs_to :state, :class_name => 'ExternalCode'

  def number_and_street
    "#{self.street_number} #{street_name}".strip
  end

  def state_name   
    self.state.code_description if self.state
  end

  def district_name
    self.district.code_description if self.district
  end

  def county_name
    self.county.code_description if self.county
  end

  protected
  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base("At least one address field must have a value")
    end
  end
end
