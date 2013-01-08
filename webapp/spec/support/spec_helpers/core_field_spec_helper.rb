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
module CoreFieldSpecHelper

  def given_core_fields_loaded
    CoreField.load!(core_fields)
  end

  def given_core_fields_loaded_for(event_type)
    fields = core_fields.select do |field_attr|
      field_attr['event_type'] == event_type.to_s
    end
    CoreField.load! fields
  end

  def given_cmr_core_tabs_loaded
    given_core_tabs_loaded_for :morbidity_event
  end

  def given_contact_core_tabs_loaded
    given_core_tabs_loaded_for :contact_event
  end

  def given_core_tabs_loaded_for(event_type)
    tabs = core_fields.select do |field_attr|
      field_attr['event_type'] == event_type.to_s and %w(tab event).include?(field_attr['field_type'])
    end
    CoreField.load! tabs
  end


  def core_fields
    @yaml_core_fields ||= YAML.load_file(File.join(File.dirname(__FILE__), '../../../db/defaults/core_fields.yml'))
  end

  def hide_morbidity_event_tabs(*tab_names_and_options)
    hide_tabs_for_event :morbidity_event, *tab_names_and_options
  end

  def hide_contact_event_tabs(*tab_names_and_options)
    hide_tabs_for_event :contact_event, *tab_names_and_options
  end

  def hide_tabs_for_event(event_type, *tab_names_and_options)
    options = tab_names_and_options.extract_options!
    tab_names_and_options.each do |tab_name|
      tab = CoreField.tab(event_type, tab_name)
      tab.update_attributes! :rendered_attributes => {
        :rendered => false,
        :disease_id => options[:on_disease].id
      }
    end
  end
end
