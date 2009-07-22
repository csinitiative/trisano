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

module PlaceManagementHelper
  def render_merge_hidden_fields
    # PLUGIN_HOOK -render_merge_hidden_fields()
  end

  def render_merge_place
    # PLUGIN_HOOK -render_merge_place()
    yield
  end

  def render_place_management_list
    place_list = ""
    place_list << render_merge_place do
      result = ""
      unless @place_entities.nil? || @place_entities.empty?
        result << "<table cellpadding='0' cellspacing='0' border='0' id='entity_search_results'>"
        result << "<tr style='text-align: left'>"
        result << "<th>Place Name</th><th>Address</th><th>Place Type</th><th>Actions</th>"

        @place_entities.each do |place_entity|
          unless is_merge_entity(place_entity) || place_entity.place.place_type_ids.include?(Code.jurisdiction_place_type_id)
            result << "<tr class='search-active tabular'>"
            result << "<td>#{h place_entity.place.name}</td>"
            result << "<td>#{render_place_address(place_entity)}</td>"
            result << "<td>#{render_place_types(place_entity)}</td>"
            result << "<td>#{render_place_actions(place_entity)}</td>"
            result << "</tr>"
          end
        end

        result << "</table>"
      end
      result
    end
    
    place_list
  end

  private

  def render_place_address(place_entity)
    result = ""
    address = place_entity.canonical_address
        
    unless address.nil?
      result << "#{h address.street_number}"
      result << "#{h address.street_name}"
      result << "#{h address.city}"
      result << "#{h address.county.code_description}" unless address.county.nil?
      result << "#{h address.state.code_description}" unless address.state.nil?
      result << "#{h address.postal_code}"
    end
    
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
    link_to("Edit", edit_place_path(place_entity))
  end

  def is_merge_entity(place_entity)
    # PLUGIN_HOOK -is_merge_entity(place_entity)
    return false
  end

end
