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

class Location < ActiveRecord::Base
  has_many :entities_locations
  has_many :entities, :through => :entities_locations
  
  has_many :addresses, :dependent => :destroy, :order => 'created_at DESC'
  has_many :telephones, :dependent => :destroy, :order => 'created_at DESC'

  has_one :current_address, :class_name => 'Address', :order => 'created_at DESC'
  has_one :current_phone, :class_name => 'Telephone', :order => 'created_at DESC'

  # Turn off auto validation of has_many associations
  def validate_associated_records_for_telephones() end
  def validate_associated_records_for_addresses() end

  validates_associated :telephones
  validates_associated :addresses

  def validate
    errors.add_to_base("Both telephones and addresses cannot be empty") if telephones.empty? && addresses.empty?
  end
end
