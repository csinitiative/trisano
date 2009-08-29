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

class HospitalizationFacility < Participation
  belongs_to :place_entity,  :foreign_key => :secondary_entity_id
  has_one :hospitals_participation, :foreign_key => :participation_id, :dependent => :destroy

  # Ordinarily we would accept nested attributes for place_entity too.  But currently we're not allowing them to add new
  # hospitals, only link to existing ones.  Change that, when asked to.
  accepts_nested_attributes_for :hospitals_participation, :reject_if => proc { |attrs| attrs.all? { |k, v| v.blank? } }

  def validate
    super
    if !hospitals_participation.nil? and place_entity.nil?
      errors.add_to_base("Hospitalization Facility can not be blank if hospitalization dates or medical record number are given.")
    end
  end

end
