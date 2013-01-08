# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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

class DiagnosticFacility < Participation
  belongs_to :place_entity,  :foreign_key => :secondary_entity_id
  accepts_nested_attributes_for :place_entity, :reject_if => :place_and_canonical_address_blank?

  class << self
    def blank
      instance = new
      instance.build_place_entity.build_place
      instance
    end
  end

  def xml_fields
    [[:secondary_entity_id, {:rel => :diagnostic_facility}]]
  end
end

