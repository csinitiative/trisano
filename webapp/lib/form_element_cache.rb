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

require 'cacheable_tree'

class FormElementCache
  include CacheableTree
  
  def initialize(root_element)
    raise(ArgumentError, "FormElementCache initialize only handles FormElements") unless root_element.is_a?(FormElement)
    @root_element = root_element
    @root_element.reload
    @full_set = load_full_set
  end
  
  def reload
    @full_set = load_full_set
  end
  
  private
  
  def load_full_set
    FormElement.find(:all,
      :conditions => "tree_id = #{@root_element.tree_id} and lft BETWEEN #{@root_element.lft} AND #{@root_element.rgt}",
      :order => "form_elements.lft",
      :include => [:question]
    )
  end
  
end
