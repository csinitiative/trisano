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

def create_form(event_type, form_name, form_short_name, disease)
  form = Form.new
  form.event_type = event_type + "_event"
  form.name = form_name
  form.short_name = "#{form_short_name}_#{get_random_word}"
  form.disease_ids = [Disease.find_by_disease_name(disease).id]
  form.save_and_initialize_form_elements
  raise "Could not create form" if form.nil?
  form
end

def create_published_form(event_type, form_name, disease)
  form = create_form(event_type, form_name, disease)
  form.publish
end

def save_new_form(form_name)
  submit_form "new_form"
  response.should contain("Form was successfully created.")
  response.should contain(form_name)
end
