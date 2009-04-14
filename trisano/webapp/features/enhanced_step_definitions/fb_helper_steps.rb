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

Given(/^a form exists with the name (.+) \((.+)\) for a (.+) with the disease (.+)$/) do |form_name, form_short_name, event_type, disease|
  @form = create_form(event_type, form_name, form_short_name, disease)
end

When(/^I go to the Builder interface for the form$/) do
  @browser.click "link=FORMS"
  @browser.wait_for_page_to_load 30000
  click_build_form_by_id(@browser, @form.id)
end
