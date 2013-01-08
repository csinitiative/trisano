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
When /^in a (.+) event, I search for a diagnostic facility named "([^\"]*)"$/ do |event_type, name|
  event_controller = event_type + "_events"
  visit url_for({ :controller => event_controller,
                  :action => :diagnostic_facilities_search,
                  :name => name })
end

When /^in a (.+) event, I search for a place exposure named "([^\"]*)"$/ do |event_type, name|
  codes = Place.epi_type_codes.map do |the_code|
    Code.find_by_code_name_and_the_code('placetype', the_code).id
  end

  event_controller = event_type + "_events"
  visit url_for({ :controller => event_controller,
                  :action => :places_search,
                  :name => name, :types => "[#{codes.join(',')}]"})
end

When /^in a (.+) event, I search for a reporting agency named "([^\"]*)"$/ do |event_type, name|
  event_controller = event_type + "_events"
  visit url_for({ :controller => event_controller,
                  :action => :reporting_agencies_search,
                  :place_name => name,
                  :event_type => 'morbidity_event' })
end

When /^I search for a contact named "([^\"]*)"$/ do |arg1|
  visit url_for({ :controller => :events,
                  :action => :contacts_search,
                  :contact_search_name => name })
end

