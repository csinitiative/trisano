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

FormElement.transaction do
  p "================ Hepatitis C ================"
  #    * 769-771, 774: A core field element container with some junk in it. Orphaned value elements and an after core field element 
  #
  # 124530 | 762 | 775 | CoreFieldElementContainer        |                          |           |    124155 | 
  # 124535 | 763 | 764 | ValueElement                             | Yes                    |           |    124534 |
  # 124536 | 765 | 766 | ValueElement                             | No                     |           |    124534 | 
  # 124537 | 767 | 768 | ValueElement                             | Unknown           |           |    124534 |
  # 124538 | 772 | 773 | AfterCoreFieldElement                |                          |           |    124531 |
  
  p "Delete the four junk rows."
  ActiveRecord::Base.connection.execute("delete from form_elements where id in (124535, 124536, 124536, 124537, 124538);")
  
  p "Insert placeholders to correct the structure"
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (526, 695, 'ValueElement', 'delete-me', 124530, 763, 772, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (526, 695, 'ValueElement', 'delete-me', 124530, 764, 765, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (526, 695, 'ValueElement', 'delete-me', 124530, 766, 767, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (526, 695, 'ValueElement', 'delete-me', 124530, 768, 769, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (526, 695, 'ValueElement', 'delete-me', 124530, 770, 771, now(), now());")
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (526, 695, 'ValueElement', 'delete-me', 124530, 773, 774, now(), now());")

  p "Delete the placeholders through the model"
  core_field_element_container = FormElement.find(124530)
  core_field_element_container.children.each do |element|
    p "Destroying element: #{element.id}, #{element.name}"
    element.destroy_and_validate
  end
  
end

FormElement.transaction do
  
  p "================ Meningococcal Disease, Invasive ================"

#  * Gaps only
#  * Missing bounds: 22, 31
#  * Single floating value set with no parent
#  * Trouble starts at id 25445
#
#  83482 |        6 |  21 | QuestionElement                  |                                        |         |     25432 | Syndrome:...
#  83485 |        7 |  20 | ValueSetElement                  | Syndrome                 |               |     83482 |
#  83486 |        8 |   9 | ValueElement                        | Bacteremia without sepsi |        |     83485 |
#  83487 |       10 |  11 | ValueElement                     | Meningitis               |                  |     83485 |
#  83488 |       12 |  13 | ValueElement                     | Meningoencephalitis      |          |     83485 |
#  83489 |       14 |  15 | ValueElement                     | Pneumonia                |               |     83485 |
#  83490 |       16 |  17 | ValueElement                     | Meningococcemia without  |      |     83485 |
#  83491 |       18 |  19 | ValueElement                     | Unknown                  |                |     83485 |
#  25445 |       23 |  30 | ValueSetElement                 | Y/N/U                    |                  |     25444 |
#  25446 |       24 |  25 | ValueElement                     | Yes                      |                    |     25445 |
#  25447 |       26 |  27 | ValueElement                     | No                       |                    |     25445 |
#  25448 |       28 |  29 | ValueElement                     | Unknown                  |               |     25445 |
#

  p "Insert placeholder to correct the structure"
  ActiveRecord::Base.connection.execute("insert into form_elements (id, form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (25444, 181, 232, 'ValueElement', 'delete-me', 25432, 22, 31, now(), now());")
  
  p "Delete the placeholder. Orphaned children will go with it."
  placeholder = FormElement.find(25444)
  placeholder.destroy_and_validate
  
end


