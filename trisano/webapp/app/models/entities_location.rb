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

class EntitiesLocation < ActiveRecord::Base
  belongs_to :location
  belongs_to :entity  

  belongs_to  :entity_location_type, :class_name => 'ExternalCode'
  belongs_to  :primary_yn, :class_name => 'ExternalCode'

  class << self
    def new_telephone_location
      el = new(:primary_yn_id => ExternalCode.no_id)
      el.build_location.telephones.build
      el
    end
  end

  # TGR - Disabled for now because it keeps addresses from saving
  # properly.
  # validates_associated :location

  # Should validate that entity_location_type and primary_yn are legitimate codes

  # Debt: a terrible hack because location wasn't working in the
  # application the way same way it did in the console.
  def telephones
    Telephone.find(:all, :conditions => ['location_id = ?', location_id])
  end
  
 
  # Convenient read only attributes make presenting telephone
  # information easier. Maybe candidates for STI.
  def area_code
    current_phone.area_code if current_phone
  end

  def phone_number
    current_phone.phone_number if current_phone
  end

  def extension
    current_phone.extension if current_phone
  end

  def email_address
    current_phone.email_address if current_phone
  end

  def current_phone
    @current_phone ||= telephones.last if telephones.last
  end

  def current_phone_exists?
    @current_phone.nil? ? false : true
  end
end
