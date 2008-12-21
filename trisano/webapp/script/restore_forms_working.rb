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

FormElement.transaction do

  p "================ Chlamydia-Gonorrhea Contacts ================"

  #    * Gap: 4-5, dupped 52 and 53
  #    * All caused by some general panic in the beginning of the form:
  #    *  4<->5, looks like a standalone question missing without the rest being adjusted
  #    * Then the bounds on the fourth question and its value set are off
  #
  # 44156 |   1 |  84 (86) | FormBaseElement                  |                          |           |           |
 
  ActiveRecord::Base.connection.execute("update form_elements set rgt = 86 where id = 44156")
  
  # 44157 |   2 |  55 | InvestigatorViewElementContainer |                          |           |     44156 |
 ActiveRecord::Base.connection.execute("update form_elements set rgt = 55 where id = 44157")
  # 
  # 44160 |   3 |  54 | ViewElement                      | Default View             |           |     44157 |
    ActiveRecord::Base.connection.execute("update form_elements set rgt = 54 where id = 44160")
  # 
  #   # insert element, 4, 5, 44160 as placeholder
  
  p "Insert placeholder to correct the structure"
  ActiveRecord::Base.connection.execute("insert into form_elements (form_id, tree_id, type, name, parent_id, lft, rgt, created_at, updated_at) values (250, 328, 'ValueElement', 'delete-me', 44160, 4, 5, now(), now());")
  
  # 75437 |   6 |   7 | QuestionElement                  |                          |           |     44160 | DIS worker number:...
  # 75444 |   8 |   9 | QuestionElement                  |                          |           |     44160 | Initiation date:...
  # 75452 |  10 |  11 | QuestionElement                  |                          |           |     44160 | New case number:...

  # 75453 |  12 |  53 (21) | QuestionElement                  |                          |           |     44160 | Does this contact have a...
  ActiveRecord::Base.connection.execute("update form_elements set rgt = 21 where id = 75453")
    
  # 75455 |  13 |  52 (20) | ValueSetElement                  | Y/N/U                    |           |     75453 |
  ActiveRecord::Base.connection.execute("update form_elements set rgt = 20 where id = 75455")
  
  # 75456 |  14 |  15 | ValueElement                     | Yes                      |           |     75455 |
  # 75457 |  16 |  17 | ValueElement                     | No                       |           |     75455 |
  
  # 75458 |  18 |  51 (19) | ValueElement                     | Unknown                  |           |     75455 |
  ActiveRecord::Base.connection.execute("update form_elements set rgt = 19 where id = 75458")

  # 75459 |  19 (22) |  50 (53)| FollowUpElement                  |                          | Yes...    |     75453 |
  ActiveRecord::Base.connection.execute("update form_elements set lft = 22, rgt = 53 where id = 75459")
  
  # 75465 |  20 (23) |  21 (24) | QuestionElement                  |                          |           |     75459 | Disease:...
  ActiveRecord::Base.connection.execute("update form_elements set lft = 23, rgt = 24 where id = 75465")
  
  # 75466 |  22 (25) |  47 (50) | QuestionElement                  |                          |           |     75459 | Disposition:...
  ActiveRecord::Base.connection.execute("update form_elements set lft = 25, rgt = 50 where id = 75466")
  
  # 75468 |  23 (26) |  46 (49) | ValueSetElement                  | disposition              |           |     75466 |
  ActiveRecord::Base.connection.execute("update form_elements set lft = 26, rgt = 49 where id = 75468")
  
  # 75469 |  24 (27) |  25 (28) | ValueElement                     | Preventative treatment   |           |     75468 |
  # 75470 |  26 (29) |  27 (30)| ValueElement                     | Refused preventative tre |           |     75468 |
  # 75471 |  28 (31)|  29 (32)| ValueElement                     | Infected, brought to tre |           |     75468 |
  # 75472 |  30 (33)|  31 (34)| ValueElement                     | Infected, not treated    |           |     75468 |
  # 75473 |  32 (35)|  33 (36)| ValueElement                     | Previously treated for t |           |     75468 |
  # 75474 |  34 (37)|  35 (38)| ValueElement                     | Not infection            |           |     75468 |
  # 75475 |  36 (39)|  37 (40)| ValueElement                     | Insufficient information |           |     75468 |
  # 75476 |  38 (41)|  39 (42)| ValueElement                     | Unable to locate         |           |     75468 |
  # 75477 |  40 (43)|  41 (44)| ValueElement                     | Located, refused exam an |           |     75468 |
  # 75478 |  42 (45)|  43 (46)| ValueElement                     | Out of jurisdiction      |           |     75468 |
  # 75479 |  44 (47)|  45 (48)| ValueElement                     | Other                    |           |     75468 |
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+3, rgt = rgt+3 where parent_id = 75468")
 
  # 75467 |  48 (51)|  49 (52)| QuestionElement                  |                          |           |     75459 | Disposition date:...
   ActiveRecord::Base.connection.execute("update form_elements set lft = 51, rgt = 52 where id = 75467")

  #   44158 |     250 |     328 |  54 (56) |  59 (61) | CoreViewElementContainer         |                          |           |     44156 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 44158")
  
  # 75454 |     250 |     328 |    55 (57) |  58 (60) | CoreViewElement                  | Demographics             |           |     44158 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75454")
  
  # 75461 |     250 |     328 |    56 (58) |  57 (59) | QuestionElement                  |                          |           |     75454 | Disposition date:...
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75461")
  
  # 44159 |     250 |     328 |  60 (62)  |  83 | CoreFieldElementContainer        |                          |           |     44156 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 44159")
  
  # 75440 |     250 |     328 |  61 |  82 | CoreFieldElement                 | Contact middle name      |           |     44159 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75440")
  
  # 75441 |     250 |     328 |  62 |  63 | BeforeCoreFieldElement           |                          |           |     75440 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75441")
  
  # 75442 |     250 |     328 |  64 |  81 | AfterCoreFieldElement            |                          |           |     75440 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75442")
  
  # 75443 |     250 |     328 |  65 |  66 | QuestionElement                  |                          |           |     75442 | AKA:...
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75443")
  
  # 75445 |     250 |     328 |  67 |  80 | QuestionElement                  |                          |           |     75442 | Marital status:...
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75445")
  
  # 75446 |     250 |     328 |  68 |  79 | ValueSetElement                  | MaritalStatus            |           |     75445 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where id = 75446")
  
  # 75447 |     250 |     328 |  69 |  70 | ValueElement                     | Single (never married)   |           |     75446 | 
  # 75448 |     250 |     328 |  71 |  72 | ValueElement                     | Separated                |           |     75446 | 
  # 75449 |     250 |     328 |  73 |  74 | ValueElement                     | Divorced                 |           |     75446 | 
  # 75450 |     250 |     328 |  75 |  76 | ValueElement                     | Widowed                  |           |     75446 | 
  # 75451 |     250 |     328 |  77 |  78 | ValueElement                     | Unknown                  |           |     75446 | 
  ActiveRecord::Base.connection.execute("update form_elements set lft = lft+2, rgt = rgt+2 where parent_id = 75446")

  p "Destroy elements through the model to get lfts and rights adjusted properly"
  elements_to_delete = FormElement.find_all_by_form_id_and_name(250, 'delete-me')

  elements_to_delete.each do |element|
    p "Destroying element: #{element.id}, #{element.name}"
    element.destroy_and_validate
  end

  

end
