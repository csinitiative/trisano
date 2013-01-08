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

module PlaceManagementHelper

  def render_place_address(place_entity)
    result = ""
    first_line = ""
    second_line = ""
    address = place_entity.canonical_address
    return if address.nil?

    first_line << "#{h address.street_number} " unless address.street_number.blank?
    first_line << "#{h address.street_name} " unless address.street_name.blank?
    first_line << "#{h address.unit_number}" unless address.unit_number.blank?

    second_line << "#{h address.city} " unless address.city.blank?
    second_line << "#{h address.county.code_description} " unless address.county.nil?
    second_line << "#{h address.state.code_description} " unless address.state.nil?
    second_line << "#{h address.postal_code}"

    result << first_line unless first_line.empty?
    result << "<br/>" if (!first_line.empty? && !second_line.empty?)
    result << second_line unless second_line.empty?
    result
  end

  def render_place_types(place_entity)
    result = ""
    unless place_entity.place.place_types.nil?
      place_entity.place.place_types.each do |place_type|
        result << "#{place_type.code_description}<br/>"
      end
    end
    result
  end

  def render_place_actions(place_entity)
    result = link_to_unless_current t('edit'), edit_place_path(place_entity)
    @extension_action_links.inject(result) do |result, link_proc|
      link_def = link_proc.call(place_entity)
      link = link_to_unless_current(link_def[:description], link_def[:link], link_def[:options])
      result + "&nbsp;|&nbsp;" + link
    end
  end

end
