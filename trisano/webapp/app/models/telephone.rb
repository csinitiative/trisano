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

class Telephone < ActiveRecord::Base
  set_table_name :telephones_temp

  belongs_to :entity
  belongs_to  :entity_location_type, :class_name => 'ExternalCode'

  validates_format_of :phone_number, :with => /^\d{3}-?\d{4}$/, :message => 'must not be blank and must be 7 digits with an optional dash (e.g.5551212 or 555-1212)', :allow_blank => true
  validates_format_of :area_code, :with => /^\d{3}$/, :message => 'must be 3 digits', :allow_blank => true
  validates_format_of :extension, :with => /^\d{1,6}$/, :message => 'must have 1 to 6 digits', :allow_blank => true

  before_save :strip_dash_from_phone

  # A basic (###) ###-#### Ext. # format for phone numbers
  def simple_format
    number = ''
    number << "(#{self.area_code}) " unless self.area_code.blank?
    if phone_number.blank? || phone_number.include?('-')
      number << (phone_number || "")
    else
      number << phone_number.insert(3, '-')
    end
    number << " Ext. #{self.extension}" unless self.extension.blank?
    number.strip
  end

  protected
  def validate
    if attributes.all? {|k, v| v.blank?}
      errors.add_to_base("At least one telephone field must have a value")
    end
  end

  def strip_dash_from_phone
    phone_number.gsub!(/-/, '')
  end

end
