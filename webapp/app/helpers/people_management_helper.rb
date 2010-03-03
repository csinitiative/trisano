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

module PeopleManagementHelper
  def render_merge_person_hidden_fields
    # PLUGIN_HOOK -render_merge_person_hidden_fields()
  end

  def render_merge_person
    # PLUGIN_HOOK -render_merge_person()
    yield
  end

  def render_person_management_list
    render_merge_person { render(:partial => 'people/people_list') }
  end

  def render_person_actions(person)
    result = ""
    logger.debug "-----> before the person links"
    result << link_to(t('edit'), edit_person_path(person.entity_id))
    result << "&nbsp;|&nbsp;"
    result << link_to(t('show'), person_path(person.entity_id))

    if User.current_user.is_entitled_to?(:create_event)
      result << "&nbsp;|&nbsp;"
      result << link_to(t('create_cmr_this_person'), cmrs_path(:from_person => person.entity_id, :return => true), :method => :post)
    end

    result
  end

  def is_person_merge_entity(person_entity)
    # PLUGIN_HOOK -is_merge_entity(person_entity)
    return false
  end

  def search_result_has_address?(record)
    [:street_number,
     :street_name,
     :unit_number,
     :city,
     :state_name,
     :postal_code].any? {|f| record[f]}
  end

  def search_result_has_second_address_block?(record)
    [:city,
     :state_name,
     :postal_code].any? {|f| record[f]}
  end

end
