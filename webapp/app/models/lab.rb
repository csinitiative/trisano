# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

class Lab < Participation
  belongs_to :place_entity, :foreign_key => :secondary_entity_id
  has_many   :lab_results, :foreign_key => :participation_id, :order => 'position, created_at ASC', :dependent => :destroy

  validates_presence_of :place_entity

  accepts_nested_attributes_for :lab_results,
    :allow_destroy => true,
    :reject_if => proc { |attrs| attrs.reject{ |k, v| k == "position" }.all? { |k, v| v.blank? } }

  accepts_nested_attributes_for :place_entity,
    :reject_if => proc { |attrs| attrs["place_attributes"].all? { |k, v| v.blank? } }

  def xml_fields
    [[:secondary_entity_id, {:rel => :lab}]]
  end
end
