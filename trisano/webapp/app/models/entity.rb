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

class Entity < ActiveRecord::Base
  set_inheritance_column :entity_type

  has_many :telephones
  has_many :email_addresses
  has_many :addresses

  has_one :place
  has_one :person

  accepts_nested_attributes_for :telephones, :email_addresses, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }, :allow_destroy => true

  attr_protected :entity_type

  def primary_phone
    self.telephones.first 
  end

  def validate
    errors.add_to_base("information is not complete.  Most likely you are adding phone or address information without a name") if (person.nil? and place.nil?)
  end
end
