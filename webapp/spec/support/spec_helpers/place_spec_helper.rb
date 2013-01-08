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
module PlaceSpecHelper

  def put_unassigned_at_the_bottom(jurisdictions)
    unassigned = jurisdictions.find { |jurisdiction| jurisdiction.read_attribute(:name) == "Unassigned" }
    jurisdictions.insert(jurisdictions.size-1, jurisdictions.delete(unassigned))
    jurisdictions
  end

  def given_an_unassigned_jurisdiction
    unassigned = Place.unassigned_jurisdiction
    if unassigned.nil?
      unassigned = create_jurisdiction_entity(:place_attributes => {:name => 'Unassigned'})
    end
    unassigned
  end
end
