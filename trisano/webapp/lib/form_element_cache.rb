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

class FormElementCache
  
  def initialize(root_element)
    raise(ArgumentError, "FormElementCache initialize only handles FormElements") unless root_element.is_a?(FormElement)
    @root_element = root_element
    @root_element.reload
    @full_set = FormElement.find(:all, 
      :conditions => "tree_id = #{root_element.tree_id} and lft BETWEEN #{root_element.lft} AND #{root_element.rgt}",
      :order => "form_elements.lft",
      :include => [:question]
    )
  end
  
  def full_set
    @full_set
  end
   
  def children(element = @root_element)
    full_set.collect { |node| if (node.parent_id == element.id)
        node
      end
    }.compact
  end
  
  def children_by_type(type, element = @root_element)
    full_set.collect { |node| if (node.parent_id == element.id && node.type == type)
        node
      end
    }.compact
  end
  
  def children_count(element = @root_element)
    full_set.collect { |node| if (node.parent_id == element.id)
        node
      end
    }.compact.size
  end
  
  def children_count_by_type(type,  element = @root_element)
    full_set.collect { |node| if (node.parent_id == element.id && node.type == type)
        node
      end
    }.compact.size
  end
  
  def all_children(element = @root_element)
    full_set.collect { |node|
      if (node.lft > element.lft && node.rgt < element.rgt)
        node
      end
    }.compact
  end
  
  def all_follow_ups_by_core_path(core_path, element = @root_element)
    full_set.collect { |node|
      if ((node.core_path == core_path) && (node.type == "FollowUpElement") && (node.lft > element.lft) && (node.rgt < element.rgt))
        node
      end
    }.compact
  end
  
  def all_cached_field_configs_by_core_path(core_path, element = @root_element)
    full_set.collect { |node|
      if ((node.core_path == core_path) && (node.type == "CoreFieldElement") && (node.lft > element.lft) && (node.rgt < element.rgt))
        node
      end
    }.compact
  end
  
  def question(element)
    full_set.detect { |node|
      if node.id == element.id
        node
      end
    }.question
  end
  
  def answer(question_element, event)
    event.answers.detect { |node| 
      if node.question_id == question(question_element).id
        node
      end
    }
  end
  
end
