# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

# Capturing the work done during the Iteration 4.6 form cleanup that
# was necessitated by early defects in form builder.
#
# This script can only be run against the 4.5 upgrade dump, against which
# cleanup work was done. It is committed mostly for reference. Restored forms
# were generated locally, exported, and delivered as exports to UT.

FormElement.transaction do
  p "================ Child Blood Lead ================"
  #11825 |       64 |  65 | ValueElement                     | Filipino                                    |     11823 |
  #56297 |       84 |  85 | ValueElement                     | Hawaiian                                    |     11823 |
  
  p "Manually insert rows to fill up value gaps"

  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 66, 67, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 68, 69, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 70, 71, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 72, 73, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 74, 75, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 76, 77, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 78, 79, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 80, 81, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (123, 133, 'ValueElement', 'delete-me', 11823, 82, 83, now(), now());")

  p "Destroy elements through the model to get lfts and rights adjusted properly"
  elements_to_delete = FormElement.find_all_by_form_id_and_name(123, 'delete-me')

  elements_to_delete.each do |element|
    p "Destroying element: #{element.id}, #{element.name}"
    element.destroy_and_validate
  end
end



