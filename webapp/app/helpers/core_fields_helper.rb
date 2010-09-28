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
    result = ""
    result << render(:partial => 'list_fields', :locals => {:event_type => t('morbidity_event_fields'), :core_fields => core_fields.select {|cf| cf.event_type == 'morbidity_event'}})
    result << render(:partial => 'list_fields', :locals => {:event_type => t('contact_event_fields'), :core_fields => core_fields.select {|cf| cf.event_type == 'contact_event'}})
    result << render(:partial => 'list_fields', :locals => {:event_type => t('place_event_fields'), :core_fields => core_fields.select {|cf| cf.event_type == 'place_event'}})
    result << render(:partial => 'list_fields', :locals => {:event_type => t('encounter_event_fields'), :core_fields => core_fields.select { |cf| cf.event_type == 'encounter_event' } })
    result
  end

  def link_back_to_core_fields(disease=nil)
    if disease
      link_to t(:back_to_disease_core_fields, :name => disease.disease_name), disease_core_fields_path
    else
      link_to t(:back_to_core_fields), core_fields_path
    end
  end

  def link_to_edit_core_field(core_field, disease=nil)
    if disease
      url = edit_disease_core_field_path(disease, core_field)
    else
      url = edit_core_field_path(core_field)
    end
    link_to t(:edit), url
  end

  def core_field_list_item(core_field, disease=nil, &block)
    cf_class = "cf-#{core_field.field_type}"
    rendered_class = core_field.rendered?(disease) ? "" : "not-rendered"
    options = { :class => "roll #{cf_class} #{rendered_class}".strip }
    content_tag :li, options, &block
  end
end
