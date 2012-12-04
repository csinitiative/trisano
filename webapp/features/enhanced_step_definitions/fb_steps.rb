# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

When /^I go to the Builder interface for the form$/ do
  @browser.click "link=ADMIN"
  @browser.wait_for_page_to_load 30000
  @browser.click "link=Manage Forms"
  @browser.wait_for_page_to_load 30000
  click_build_form_by_id(@browser, @form.id)
end

Given /^that form has core field configs configured for all core fields$/ do
  @core_field_container = @form.core_field_elements_container

  # Create a core field config for every core field
  CoreField.all(:conditions => ['event_type = ? and fb_accessible = true and disease_specific != true', @form.event_type]).each do |core_field|
    create_core_field_config(@form, @core_field_container, core_field)
  end
end
