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

def path_to(page_name)
  case page_name

  when /the homepage/i
    root_path

  when /the admin dashboard page/i
    admin_path
  
  when /the jurisdictions page/i
    jurisdictions_path

  when /the show jurisdiction page/i
    jurisdiction_path

  when /the new CMR page/i
    new_cmr_path

  when /the show CMR page/i
    cmr_path @event

  when /the contact edit page/i
    edit_contact_event_path(@contact_event)

  when /the contact show page/i
    contact_event_path(@contact_event)

  when /the add and remove forms page/i
    event_forms_path(@event)

  when /the investigator user edit page/i
    "/users/4/edit"

  when /the common test type index page/
    common_test_types_path

  when /the new common test type page/
    new_common_test_type_path

  when /(a|the) common test type show page/
    common_test_type_path(@common_test_type)

  when /edit the common test type/
    edit_common_test_type_path(@common_test_type)

  when /manage the common test type\'s loinc codes/
    loinc_codes_common_test_type_path(@common_test_type)

  when /the admin dashboard/
    admin_path

  when /the places page/
    places_path

  when /the new place page/
    new_place_path

  when /the "([^"]*)" place show page/
    place_path(PlaceEntity.find(:first, :conditions => ["places.name = ?", $1], :include => :place))

  when /the place edit page/
    edit_place_path(@place_entity)

  when /edit the disease/
    edit_disease_path(@disease)

  when /the loinc code index page/
    loinc_codes_path

  when /the new loinc code page/
    new_loinc_code_path

  when /edit the loinc code/
    edit_loinc_code_path @loinc_code

  when /the "([^"]*)" edit loinc code page/
    edit_loinc_code_path LoincCode.find_by_loinc_code($1)

  when /the loinc code show page/
    loinc_code_path @loinc_code

  when /the "([^"]*)" loinc code page/
    loinc_code_path LoincCode.find_by_loinc_code($1)

  when /the users index page/
    users_path

  when /view the default user/
    user_path User.find_by_user_name('default_user')

  when /the new user page/
    new_user_path

  when /edit the user/
    edit_user_path @user

  when /the "([^"]*)" organism page/
    organism_path Organism.find_by_organism_name($1)

  when /the "([^"]*)" edit organism page/
    edit_organism_path Organism.find_by_organism_name($1)

  when /the new organism page/
    new_organism_path

  when /the organisms index page/
    organisms_path

  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end
