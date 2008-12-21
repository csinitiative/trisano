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

p "Retriveing all library trees"
library_tree_roots = FormElement.find(:all, :conditions => "parent_id is null and type != 'FormBaseElement' and form_id is null")

library_tree_roots.each do |root|
  begin
    root.validate_tree_structure(root)
    p "Tree #{root.tree_id} is OK"
  rescue
    p "Tree #{root.tree_id} is invalid"
    p root.errors
  end
end