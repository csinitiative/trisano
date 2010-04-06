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

Then /^I should see all of the core field config questions$/ do
  html_source = @browser.get_html_source
  CoreField.find_all_by_event_type_and_fb_accessible(@form.event_type, true).each do |core_field|
    raise "Could not find before config for #{core_field.name}" if html_source.include?("#{core_field.name} before?") == false
    raise "Could not find after config for #{core_field.name}" if html_source.include?("#{core_field.name} after?") == false
  end
end

When /^I answer all core field config questions$/ do
  # Also fill in one address field so the address will show up in show mode
  @browser.type("#{@form.event_type}[address_attributes][street_number]", "12") if ["morbidity_event", "contact_event", "place_event"].include? @form.event_type
  
  html_source = @browser.get_html_source
  CoreField.find_all_by_event_type_and_fb_accessible(@form.event_type, true).each do |core_field|
    answer_investigator_question(@browser, "#{core_field.name} before?", "#{core_field.name} before answer", html_source).should be_true
    answer_investigator_question(@browser, "#{core_field.name} after?", "#{core_field.name} after answer", html_source).should be_true
  end
end

Then /^I should see all core field config answers$/ do
  html_source = @browser.get_html_source
  CoreField.find_all_by_event_type_and_fb_accessible(@form.event_type, true).each do |core_field|
    raise "Could not find before answer for #{core_field.name}" if html_source.include?("#{core_field.name} before answer") == false
    raise "Could not find after answer for #{core_field.name}" if html_source.include?("#{core_field.name} after answer") == false
  end
end