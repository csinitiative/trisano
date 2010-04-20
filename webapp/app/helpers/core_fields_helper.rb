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

module CoreFieldsHelper
  extensible_helper

  def render_core_fields_list(core_fields)
    returning "" do |result|
      result << render(:partial => 'list_fields', :locals => {:event_type => t('morbidity_event_fields'), :core_fields => core_fields.select {|cf| cf.event_type == 'morbidity_event'}})
      result << render(:partial => 'list_fields', :locals => {:event_type => t('contact_event_fields'), :core_fields => core_fields.select {|cf| cf.event_type == 'contact_event'}})
      result << render(:partial => 'list_fields', :locals => {:event_type => t('place_event_fields'), :core_fields => core_fields.select {|cf| cf.event_type == 'place_event'}})
      result << render(:partial => 'list_fields', :locals => {:event_type => t('encounter_event_fields'), :core_fields => core_fields.select { |cf| cf.event_type == 'encounter_event' } })
    end
  end
end
