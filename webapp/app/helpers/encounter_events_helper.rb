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

module EncounterEventsHelper
  extensible_helper

  def encounter_event_tabs
    event_tabs_for :encounter_event
  end

  # Builds a list of users for use in the investigator drop down for encounter events. It
  # adds the current user to the front of the list if the current user isn't included in the
  # results pulled back based on permissions.
  def users_for_investigation_select(encounter)
    place_entity = encounter.jurisdiction.try(:place_entity) || encounter.parent_event.try(:jurisdiction).try(:place_entity)
    users = User.investigators_for_jurisdictions(place_entity)
    users.unshift(User.current_user) unless users.include?(User.current_user)
    if encounter.investigator && !users.include?(encounter.investigator)
      users.unshift(encounter.investigator)
    end
    users
  end

  def expire_event_caches()
    if params['expire_cache_all']
      redis.delete_matched("views/events/#{@event.id}/*")
    elsif params['expire_cache']
      params['expire_cache'].each do |key, value|
        redis.delete_matched("views/events/#{@event.id}/edit/#{key}*")
        redis.delete_matched("views/events/#{@event.id}/show/#{key}*")
        redis.delete_matched("views/events/#{@event.id}/showedit/#{key}*")
      end
    end
  end

  def basic_encounter_event_controls(event, with_show=true)
    controls = ""
    controls << link_to_function(t('show'), "send_url_with_tab_index('#{encounter_event_path(event)}')") if with_show

    if User.current_user.can_update? event
      controls <<  " | "  if with_show
      controls << link_to_function(t('edit'), "send_url_with_tab_index('#{edit_encounter_event_path(event)}')")
      if event.deleted_at.nil?
        controls <<  " | "
        controls << link_to(t('delete'), soft_delete_encounter_event_path(event), :method => :post, :confirm => 'Are you sure?', :id => 'soft-delete')
      end
    end

    controls
  end

end
