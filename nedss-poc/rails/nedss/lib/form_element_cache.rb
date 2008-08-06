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
  
end
