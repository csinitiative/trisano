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

# Capturing the work done during the Iteration 4.6 form cleanup that
# was necessitated by early defects in form builder.
#
# This script can only be run against the 4.5 upgrade dump, against which
# cleanup work was done. It is committed mostly for reference. Restored forms
# were generated locally, exported, and delivered as exports to UT.

corrupt_form_ids = [214, 80, 123, 250, 209, 550, 526, 181, 1, 202, 175]
# Listeria: 217

corrupt_form_ids.each do |form_id|
  
  FormElement.transaction do
     corrupt_form = Form.find(form_id)
    
    p "========== Restoring #{corrupt_form.name} =========="
    new_form = Form.new
    new_form.name = "#{corrupt_form.name} -- Restored"
    new_form.event_type = 'morbidity_event'
    new_form.is_template = 'true'
    new_form.status = 'Not Published'
    new_form.save!
    tree_id = FormElement.next_tree_id
    original_root = FormElement.find_by_form_id_and_type_and_lft_and_parent_id(corrupt_form.id, "FormBaseElement", 1, nil)
    original_root.copy_children(original_root, nil, new_form.id, tree_id, true)

    unless new_form.structure_valid?
      p new_form.errors
      raise
    end

  end
end
