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

  # Add more page name => path mappings here
  when /the new CMR page/i
    new_cmr_path

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

  when /edit the disease/
    edit_disease_path(@disease)

  when /the loinc code index page/
    loinc_codes_path

  when /the new loinc code page/
    new_loinc_code_path

  else
    raise "Can't find mapping from \"#{page_name}\" to a path."
  end
end
