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

Then /^I should see all of the core field config questions$/ do
  CoreField.find_all_by_event_type_and_fb_accessible(@form.event_type, true).each do |core_field|
    response.should contain("#{core_field.name} before?")
    response.should contain("#{core_field.name} after?")
  end
end

When /^I answer all core field config questions$/ do
  CoreField.find_all_by_event_type_and_fb_accessible(@form.event_type, true).each do |core_field|
    fill_in("#{core_field.name} before?", :with => "#{core_field.name} before answer")
    fill_in("#{core_field.name} after?", :with => "#{core_field.name} after answer")
  end
end

When /^I save the event$/i do
  if @contact_event
    submit_form "edit_contact_event_#{@contact_event.id}"
  else
    submit_form "edit_morbidity_event_#{@event.id}"
  end
end

Then /^I should see all core field config answers$/ do
  CoreField.find_all_by_event_type_and_fb_accessible(@form.event_type, true).each do |core_field|
    response.should contain("#{core_field.name} before answer")
    response.should contain("#{core_field.name} after answer")
  end
end
