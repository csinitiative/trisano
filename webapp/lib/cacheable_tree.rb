# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

module CacheableTree
  
  def full_set
    @full_set
  end
  
  def each
    @full_set.each {|element| yield element}
  end
   
  def children?(element = @root_element)
    children_count(element)
  end
  
  def children(element = @root_element)
    @children ||= {}
    #@children[element] ||= full_set.select { |node| node.parent_id == element.id }
    @children[element] ||= FormElement.find_by_sql("SELECT * FROM form_elements WHERE (tree_id = #{element.tree_id} AND (lft BETWEEN #{element.lft} AND #{element.rgt}) AND parent_id = #{element.id}) ORDER BY form_elements.lft")
  end
  
  def children_by_type(type, element = @root_element)
    full_set.collect { |node| if (node.parent_id == element.id && node.class.name == type.to_s)
        node
      end
    }.compact
  end
  
  def children_count(element = @root_element)
    children(element).size
  end
  
  def children_count_by_type(type,  element = @root_element)
    full_set.collect { |node| if (node.parent_id == element.id && node.class.name == type.to_s)
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
      if ((node.core_path == core_path) && (node.class.name == "FollowUpElement") && (node.lft > element.lft) && (node.rgt < element.rgt))
        node
      end
    }.compact
  end
  
  def all_cached_field_configs_by_core_path(core_path, element = @root_element)
    full_set.collect { |node|
      if ((node.core_path == core_path) && (node.class.name == "CoreFieldElement") && (node.lft > element.lft) && (node.rgt < element.rgt))
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

  def exportable_questions
    full_set.collect{|node|
      if ((node.class.name == "QuestionElement") && !node.question.short_name.blank?)
        node.question
      end
    }.compact
  end
  
end
