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

class EntitiesLocation < ActiveRecord::Base
  belongs_to :location, :dependent => :destroy
  belongs_to :entity

  belongs_to  :entity_location_type, :class_name => 'ExternalCode'
  belongs_to  :primary_yn, :class_name => 'ExternalCode'

  class << self
    def new_telephone_location
      el = new(:primary_yn_id => ExternalCode.no_id,
               :location_type_id => Code.telephone_location_type_id)
      el.build_location.telephones.build
      el
    end

    def new_address_location
      el = new(:primary_yn_id => ExternalCode.yes_id,
               :location_type_id => Code.address_location_type_id)
      el.build_location.addresses.build
      el
    end
  end

  validates_associated :location

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
    location.telephones.last if location.telephones.last
  end

  def current_phone_exists?
    current_phone.nil? ? false : true
  end
end
