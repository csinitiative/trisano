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

class Jurisdiction < Participation
  belongs_to :place_entity,  :foreign_key => :secondary_entity_id
  accepts_nested_attributes_for :place_entity, :reject_if => proc { |attrs| attrs["place_attributes"].all? { |k, v| v.blank? } }

  # wrapped User#is_entitled_to_in?, frankly, because it's easier to
  # stub workflow this way.
  def allows_current_user_to?(privilege)
    User.current_user.is_entitled_to_in?(privilege, secondary_entity_id)
  end

  def self.out_of_state
    Place.find_by_name("Out of State")
  end

  def place
    place_entity.try :place
  end

  def name
    place.try :name
  end

  def short_name
    place.try :short_name
  end

  def xml_fields
    [[:secondary_entity_id, {:rel => :jurisdiction}]]
  end
end
