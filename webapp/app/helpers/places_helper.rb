# Copyright (C) 2007, 2008, 2009, 2010 The Collaborative Software Foundation
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

module PlacesHelper
  def diagnostic_type_selector(form)
    render_type_selector(form, 'diagnostic_types')
  end

  def epi_type_selector(form)
    render_type_selector(form, 'epi_types')
  end

  def agency_type_selector(form)
    render_type_selector(form, 'agency_types')
  end

  def exposed_type_selector(form)
    render_type_selector(form, 'exposed_types')
  end

  def render_type_selector(form, types)
    render :partial => 'events/place_types', :locals => { :f => form, :types => types}
  end

  def i18n_jurisdiction_short_name(raw_shortname)
    if raw_shortname == "Unassigned"
      Place.unassigned_jurisdiction.short_name
    else
      return raw_shortname
    end
  end

  def preferred_address(place)
    address = place.safe_call_chain(:entity, :canonical_address) || place.safe_call_chain(:entity, :addresses, :last)
    if address
      result = []
      result << address.street_number
      result << address.street_name
      result << address.city
      result << address.county.try(:code_description)
      result << address.postal_code
      result.compact.join("\n")
    else
      ""
    end
  end
end
